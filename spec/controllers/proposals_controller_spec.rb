# frozen_string_literal: true

require 'rails_helper'

# NOTE: Skipped because the routes for ProposalsController are commented out in routes.rb
# The proposals functionality has been moved to the PlebisProposals engine.
# See: config/routes.rb lines 100-102 (commented out)
# The engine's ProposalsController (PlebisProposals::ProposalsController) handles all proposal routes
RSpec.describe ProposalsController, type: :controller, skip: 'Routes disabled - proposals handled by PlebisProposals engine' do
  let(:user) { create(:user, :with_dni) }
  let(:proposal) { create(:proposal, :active) }
  let(:finished_proposal) { create(:proposal, :finished) }

  before do
    # Skip ApplicationController filters for isolation
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Use engine routes for ProposalsController (it's in PlebisProposals engine)
    @routes = PlebisProposals::Engine.routes
  end

  # ==================== INDEX ACTION TESTS ====================

  describe 'GET #index' do
    context 'without filter parameter' do
      it 'defaults to popular filter' do
        get :index
        expect(assigns(:proposals)).to be_present
      end

      it 'sets filter to popular' do
        get :index
        expect(params[:filter]).to eq('popular')
      end

      it 'returns success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'with filter parameter' do
      it 'uses provided filter' do
        get :index, params: { filter: 'new' }
        expect(assigns(:proposals)).to be_present
      end

      it 'accepts hot filter' do
        get :index, params: { filter: 'hot' }
        expect(response).to have_http_status(:success)
      end

      it 'accepts top filter' do
        get :index, params: { filter: 'top' }
        expect(response).to have_http_status(:success)
      end

      it 'accepts new filter' do
        get :index, params: { filter: 'new' }
        expect(response).to have_http_status(:success)
      end

      it 'accepts popular filter' do
        get :index, params: { filter: 'popular' }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with hot proposals' do
      before do
        create_list(:proposal, 3, :reddit_active)
      end

      it 'assigns hot proposals' do
        get :index
        expect(assigns(:hot)).to be_present
      end

      it 'limits hot proposals to 3' do
        get :index
        expect(assigns(:hot).size).to be <= 3
      end

      it 'uses reddit scope for hot proposals' do
        expect(Proposal).to receive_message_chain(:reddit, :hot, :limit).and_return([])
        get :index
      end
    end

    context 'with error in index' do
      before do
        allow(Proposal).to receive(:filter).and_raise(StandardError.new('Database error'))
      end

      it 'handles errors gracefully' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns empty proposals on error' do
        get :index
        expect(assigns(:proposals)).to eq(Proposal.none)
      end

      it 'assigns empty hot array on error' do
        get :index
        expect(assigns(:hot)).to eq([])
      end

      it 'sets flash alert' do
        get :index
        expect(flash.now[:alert]).to eq(I18n.t('errors.messages.generic'))
      end

      it 'logs error event' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :index
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/proposals_index_error/)).at_least(:once)
      end

      it 'includes filter in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :index
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"filter":"popular"/)).at_least(:once)
      end
    end

    context 'security logging' do
      it 'logs index view event' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/proposals_index_viewed/)).at_least(:once)
      end

      it 'includes filter in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index, params: { filter: 'hot' }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"filter":"hot"/)).at_least(:once)
      end

      it 'includes IP address in log' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address":/)).at_least(:once)
      end

      it 'includes user agent in log' do
        request.env['HTTP_USER_AGENT'] = 'Test Browser'
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent":"Test Browser"/)).at_least(:once)
      end

      it 'includes timestamp in log' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)).at_least(:once)
      end

      it 'includes controller name in log' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"controller":"proposals"/)).at_least(:once)
      end
    end

    context 'public access' do
      it 'allows unauthenticated access' do
        get :index
        expect(response).not_to redirect_to(new_user_session_path)
      end

      it 'allows authenticated access' do
        sign_in user
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  # ==================== SHOW ACTION TESTS ====================

  describe 'GET #show' do
    context 'with valid proposal' do
      it 'returns success' do
        get :show, params: { id: proposal.id }
        expect(response).to have_http_status(:success)
      end

      it 'renders show template' do
        get :show, params: { id: proposal.id }
        expect(response).to render_template(:show)
      end

      it 'assigns the proposal' do
        get :show, params: { id: proposal.id }
        expect(assigns(:proposal)).to eq(proposal)
      end

      it 'uses reddit scope' do
        expect(Proposal).to receive_message_chain(:reddit, :find).and_return(proposal)
        get :show, params: { id: proposal.id }
      end

      it 'logs security event' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/proposal_viewed/)).at_least(:once)
      end

      it 'includes proposal_id in log' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"proposal_id":#{proposal.id}/)).at_least(:once)
      end
    end

    context 'with non-existent proposal' do
      it 'handles RecordNotFound' do
        get :show, params: { id: 99_999 }
        expect(response).to redirect_to(proposals_path)
      end

      it 'sets error alert' do
        get :show, params: { id: 99_999 }
        expect(flash[:alert]).to eq(I18n.t('errors.messages.not_found'))
      end

      it 'logs not found event' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: 99_999 }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/proposal_not_found/)).at_least(:once)
      end

      it 'includes proposal_id in log' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: 99_999 }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"proposal_id":99999/)).at_least(:once)
      end
    end

    context 'with general error' do
      before do
        allow(Proposal).to receive_message_chain(:reddit, :find).and_raise(StandardError.new('Database error'))
        allow(Rails.logger).to receive(:error).and_call_original
      end

      it 'handles errors gracefully' do
        get :show, params: { id: proposal.id }
        expect(response).to redirect_to(proposals_path)
      end

      it 'sets generic error alert' do
        get :show, params: { id: proposal.id }
        expect(flash[:alert]).to eq(I18n.t('errors.messages.generic'))
      end

      it 'logs error event' do
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/proposal_show_error/)).at_least(:once)
      end

      it 'includes error class in log' do
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_class":"StandardError"/)).at_least(:once)
      end

      it 'includes error message in log' do
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_message":"Database error"/)).at_least(:once)
      end

      it 'includes backtrace in log' do
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"backtrace":/)).at_least(:once)
      end
    end

    context 'public access' do
      it 'allows unauthenticated access' do
        get :show, params: { id: proposal.id }
        expect(response).not_to redirect_to(new_user_session_path)
      end

      it 'allows authenticated access' do
        sign_in user
        get :show, params: { id: proposal.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'security logging' do
      it 'logs IP address' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address":/)).at_least(:once)
      end

      it 'logs user agent' do
        request.env['HTTP_USER_AGENT'] = 'Test Browser'
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent":"Test Browser"/)).at_least(:once)
      end

      it 'logs timestamp' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)).at_least(:once)
      end

      it 'logs controller name' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :show, params: { id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"controller":"proposals"/)).at_least(:once)
      end
    end
  end

  # ==================== INFO ACTION TESTS ====================

  describe 'GET #info' do
    it 'returns success' do
      get :info
      expect(response).to have_http_status(:success)
    end

    it 'renders info template' do
      get :info
      expect(response).to render_template(:info)
    end

    it 'logs security event' do
      allow(Rails.logger).to receive(:info).and_call_original
      get :info
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/proposals_info_viewed/)).at_least(:once)
    end

    it 'allows unauthenticated access' do
      get :info
      expect(response).not_to redirect_to(new_user_session_path)
    end

    it 'allows authenticated access' do
      sign_in user
      get :info
      expect(response).to have_http_status(:success)
    end

    context 'with error' do
      before do
        allow(controller).to receive(:render).and_raise(StandardError.new('Render error'))
        allow(Rails.logger).to receive(:error).and_call_original
      end

      it 'handles errors gracefully' do
        get :info
        expect(response).to redirect_to(proposals_path)
      end

      it 'sets error alert' do
        get :info
        expect(flash[:alert]).to eq(I18n.t('errors.messages.generic'))
      end

      it 'logs error event' do
        get :info
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/proposals_info_error/)).at_least(:once)
      end

      it 'includes error class in log' do
        get :info
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_class":"StandardError"/)).at_least(:once)
      end

      it 'includes error message in log' do
        get :info
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_message":"Render error"/)).at_least(:once)
      end
    end

    context 'security logging' do
      it 'logs IP address' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :info
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address":/)).at_least(:once)
      end

      it 'logs user agent' do
        request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0'
        allow(Rails.logger).to receive(:info).and_call_original
        get :info
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent":"Mozilla\/5.0"/)).at_least(:once)
      end

      it 'logs timestamp' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :info
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)).at_least(:once)
      end

      it 'logs controller name' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :info
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"controller":"proposals"/)).at_least(:once)
      end
    end
  end

  # ==================== INTEGRATION TESTS ====================

  describe 'integration with models' do
    describe 'Proposal.filter' do
      it 'calls filter with provided parameter' do
        expect(Proposal).to receive(:filter).with('new').and_return(Proposal.none)
        get :index, params: { filter: 'new' }
      end

      it 'calls filter with default popular' do
        expect(Proposal).to receive(:filter).with('popular').and_return(Proposal.none)
        get :index
      end
    end

    describe 'Proposal.reddit' do
      it 'calls reddit scope for hot proposals' do
        reddit_scope = double
        allow(Proposal).to receive(:reddit).and_return(reddit_scope)
        expect(reddit_scope).to receive(:hot).and_return(double(limit: []))
        get :index
      end

      it 'calls reddit scope for show action' do
        reddit_scope = double
        allow(Proposal).to receive(:reddit).and_return(reddit_scope)
        expect(reddit_scope).to receive(:find).with(proposal.id.to_s).and_return(proposal)
        get :show, params: { id: proposal.id }
      end
    end
  end

  # ==================== FLASH MESSAGE TESTS ====================

  describe 'flash messages' do
    it 'uses I18n for not_found error' do
      get :show, params: { id: 99_999 }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.not_found'))
    end

    it 'uses I18n for generic error' do
      allow(Proposal).to receive(:filter).and_raise(StandardError)
      get :index
      expect(flash.now[:alert]).to eq(I18n.t('errors.messages.generic'))
    end

    it 'uses flash.now for index errors' do
      allow(Proposal).to receive(:filter).and_raise(StandardError)
      get :index
      expect(flash.now[:alert]).to be_present
    end

    it 'uses flash redirect for show errors' do
      get :show, params: { id: 99_999 }
      expect(flash[:alert]).to be_present
    end
  end

  # ==================== PARAMETER HANDLING TESTS ====================

  describe 'parameter handling' do
    it 'accepts numeric id' do
      get :show, params: { id: 123 }
      expect(response).to be_redirect # Will redirect if not found, but accepts numeric
    end

    it 'accepts string id' do
      get :show, params: { id: '123' }
      expect(response).to be_redirect # Will redirect if not found, but accepts string
    end

    it 'handles missing id parameter' do
      expect { get :show, params: {} }.to raise_error(ActionController::UrlGenerationError)
    end

    it 'accepts various filter values' do
      %w[hot new top popular].each do |filter|
        get :index, params: { filter: filter }
        expect(response).to have_http_status(:success)
      end
    end

    it 'defaults filter when nil' do
      get :index, params: { filter: nil }
      expect(params[:filter]).to eq('popular')
    end
  end

  # ==================== ERROR LOGGING TESTS ====================

  describe 'error logging' do
    it 'logs error class and message' do
      allow(Proposal).to receive(:filter).and_raise(StandardError.new('Test error'))
      allow(Rails.logger).to receive(:error).and_call_original
      get :index
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/proposals_index_error/)).at_least(:once)
    end

    it 'logs backtrace with first 5 lines' do
      allow(Proposal).to receive(:filter).and_raise(StandardError.new('Error'))
      allow(Rails.logger).to receive(:error).and_call_original
      get :index
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/"backtrace":\[/)).at_least(:once)
    end

    it 'logs IP address in errors' do
      allow(Rails.logger).to receive(:info).and_call_original
      get :show, params: { id: 99_999 }
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address":/)).at_least(:once)
    end

    it 'logs controller in errors' do
      allow(Proposal).to receive_message_chain(:reddit, :find).and_raise(StandardError)
      allow(Rails.logger).to receive(:error).and_call_original
      get :show, params: { id: proposal.id }
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/"controller":"proposals"/)).at_least(:once)
    end

    it 'logs timestamp in errors' do
      allow(Proposal).to receive_message_chain(:reddit, :find).and_raise(StandardError)
      allow(Rails.logger).to receive(:error).and_call_original
      get :show, params: { id: proposal.id }
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T/)).at_least(:once)
    end
  end

  # ==================== REDIRECT TESTS ====================

  describe 'redirects' do
    it 'redirects to proposals_path on show not found' do
      get :show, params: { id: 99_999 }
      expect(response).to redirect_to(proposals_path)
    end

    it 'redirects to proposals_path on show error' do
      allow(Proposal).to receive_message_chain(:reddit, :find).and_raise(StandardError)
      get :show, params: { id: proposal.id }
      expect(response).to redirect_to(proposals_path)
    end

    it 'redirects to proposals_path on info error' do
      allow(controller).to receive(:render).and_raise(StandardError)
      get :info
      expect(response).to redirect_to(proposals_path)
    end

    it 'does not redirect on successful index' do
      get :index
      expect(response).not_to be_redirect
    end

    it 'does not redirect on successful show' do
      get :show, params: { id: proposal.id }
      expect(response).not_to be_redirect
    end

    it 'does not redirect on successful info' do
      get :info
      expect(response).not_to be_redirect
    end
  end

  # ==================== TEMPLATE RENDERING TESTS ====================

  describe 'template rendering' do
    it 'renders index template by default' do
      get :index
      expect(response).to render_template('proposals/index')
    end

    it 'renders show template for proposal' do
      get :show, params: { id: proposal.id }
      expect(response).to render_template('proposals/show')
    end

    it 'renders info template' do
      get :info
      expect(response).to render_template('proposals/info')
    end

    it 'does not render on error redirects' do
      get :show, params: { id: 99_999 }
      expect(response).not_to render_template('proposals/show')
    end
  end

  # ==================== INSTANCE VARIABLE ASSIGNMENT TESTS ====================

  describe 'instance variable assignments' do
    it 'assigns @proposals in index' do
      get :index
      expect(assigns(:proposals)).to be_present
    end

    it 'assigns @hot in index' do
      get :index
      expect(assigns(:hot)).to be_present
    end

    it 'assigns @proposal in show' do
      get :show, params: { id: proposal.id }
      expect(assigns(:proposal)).to eq(proposal)
    end

    it 'does not assign @proposal on error' do
      get :show, params: { id: 99_999 }
      expect(assigns(:proposal)).to be_nil
    end

    it 'assigns empty @proposals on index error' do
      allow(Proposal).to receive(:filter).and_raise(StandardError)
      get :index
      expect(assigns(:proposals)).to eq(Proposal.none)
    end

    it 'assigns empty @hot on index error' do
      allow(Proposal).to receive(:filter).and_raise(StandardError)
      get :index
      expect(assigns(:hot)).to eq([])
    end
  end
end
