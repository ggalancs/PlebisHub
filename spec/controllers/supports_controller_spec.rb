# frozen_string_literal: true

require 'rails_helper'

# NOTE: Skipped because the route for SupportsController is commented out in routes.rb
# The proposal supports functionality is now handled by PlebisProposals engine
# See: config/routes.rb line 103 (commented: #post '/apoyar/:proposal_id', to: 'supports#create')
RSpec.describe SupportsController, type: :controller, skip: 'Route is disabled - supports handled by PlebisProposals engine' do

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

    # Use main app routes - define the route inline since it's commented out in main routes
    @routes = Rails.application.routes
    Rails.application.routes.draw do
      unless Rails.application.routes.named_routes.key?(:proposal_supports)
        post '/apoyar/:proposal_id', to: 'supports#create', as: 'proposal_supports'
      end
    end
  end

  # ==================== AUTHENTICATION TESTS ====================

  describe 'authentication' do
    it 'requires authentication for create action' do
      post :create, params: { proposal_id: proposal.id }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows authenticated users to access create' do
      sign_in user
      allow(proposal).to receive(:supportable?).and_return(true)
      allow(Proposal).to receive(:find).and_return(proposal)
      post :create, params: { proposal_id: proposal.id }
      expect(response).not_to redirect_to(new_user_session_path)
    end
  end

  # ==================== CREATE SUPPORT TESTS ====================

  describe 'POST #create' do
    context 'with valid supportable proposal' do
      before do
        sign_in user
        allow(Proposal).to receive(:find).and_return(proposal)
        allow(proposal).to receive(:supportable?).with(user).and_return(true)
      end

      it 'creates a new support' do
        expect do
          post :create, params: { proposal_id: proposal.id }
        end.to change(Support, :count).by(1)
      end

      it 'associates support with proposal' do
        post :create, params: { proposal_id: proposal.id }
        expect(Support.last.proposal).to eq(proposal)
      end

      it 'associates support with current user' do
        post :create, params: { proposal_id: proposal.id }
        expect(Support.last.user).to eq(user)
      end

      it 'redirects to proposal page' do
        post :create, params: { proposal_id: proposal.id }
        expect(response).to redirect_to(proposal_path(proposal))
      end

      it 'sets success notice' do
        post :create, params: { proposal_id: proposal.id }
        expect(flash[:notice]).to eq(I18n.t('supports.created'))
      end

      it 'logs security event for support creation' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/support_created/)).at_least(:once)
      end

      it 'includes user_id in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_id":#{user.id}/)).at_least(:once)
      end

      it 'includes proposal_id in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"proposal_id":#{proposal.id}/)).at_least(:once)
      end
    end

    context 'with non-supportable proposal' do
      before do
        sign_in user
        allow(Proposal).to receive(:find).and_return(proposal)
        allow(proposal).to receive(:supportable?).with(user).and_return(false)
      end

      it 'does not create support' do
        expect do
          post :create, params: { proposal_id: proposal.id }
        end.not_to change(Support, :count)
      end

      it 'redirects to proposal page' do
        post :create, params: { proposal_id: proposal.id }
        expect(response).to redirect_to(proposal_path(proposal))
      end

      it 'sets error alert' do
        post :create, params: { proposal_id: proposal.id }
        expect(flash[:alert]).to eq(I18n.t('errors.messages.cannot_support'))
      end

      it 'logs security event for non-supportable attempt' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/support_not_supportable/)).at_least(:once)
      end

      it 'includes user_id in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: proposal.id }
      end

      it 'includes proposal_id in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"proposal_id":#{proposal.id}/)).at_least(:once)
      end
    end

    context 'with non-existent proposal' do
      before { sign_in user }

      it 'handles ActiveRecord::RecordNotFound' do
        post :create, params: { proposal_id: 99_999 }
        expect(response).to redirect_to(proposals_path)
      end

      it 'sets error alert' do
        post :create, params: { proposal_id: 99_999 }
        expect(flash[:alert]).to eq(I18n.t('errors.messages.not_found'))
      end

      it 'logs security event for not found' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: 99_999 }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/support_proposal_not_found/)).at_least(:once)
      end

      it 'includes user_id in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: 99_999 }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_id":#{user.id}/)).at_least(:once)
      end

      it 'includes proposal_id in security log' do
        allow(Rails.logger).to receive(:info).and_call_original
        post :create, params: { proposal_id: 99_999 }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"proposal_id":99999/)).at_least(:once)
      end
    end

    context 'with duplicate support' do
      before do
        sign_in user
        allow(Proposal).to receive(:find).and_return(proposal)
        allow(proposal).to receive(:supportable?).with(user).and_return(true)
        # Create existing support
        create(:support, user: user, proposal: proposal)
        allow(Rails.logger).to receive(:error).and_call_original
      end

      it 'handles RecordInvalid error' do
        post :create, params: { proposal_id: proposal.id }
        expect(response).to redirect_to(proposal_path(proposal))
      end

      it 'sets error alert' do
        post :create, params: { proposal_id: proposal.id }
        expect(flash[:alert]).to eq(I18n.t('errors.messages.support_failed'))
      end

      it 'logs error for creation failure' do
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/support_creation_failed/)).at_least(:once)
      end

      it 'includes error class in log' do
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_class":/)).at_least(:once)
      end

      it 'includes error message in log' do
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_message":/)).at_least(:once)
      end
    end

    context 'with general error' do
      before do
        sign_in user
        allow(Proposal).to receive(:find).and_return(proposal)
        allow(proposal).to receive(:supportable?).and_raise(StandardError.new('Database error'))
      end

      it 'handles StandardError' do
        post :create, params: { proposal_id: proposal.id }
        expect(response).to redirect_to(proposals_path)
      end

      it 'sets generic error alert' do
        post :create, params: { proposal_id: proposal.id }
        expect(flash[:alert]).to eq(I18n.t('errors.messages.generic'))
      end

      it 'logs error event' do
        allow(Rails.logger).to receive(:error).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/support_creation_error/)).at_least(:once)
      end

      it 'includes backtrace in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        post :create, params: { proposal_id: proposal.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"backtrace":/)).at_least(:once)
      end
    end
  end

  # ==================== SECURITY LOGGING TESTS ====================

  describe 'security logging' do
    before { sign_in user }

    it 'logs IP address' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address":/)).at_least(:once)
    end

    it 'logs user agent' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      request.env['HTTP_USER_AGENT'] = 'Test Browser'
      allow(Rails.logger).to receive(:info).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent":"Test Browser"/)).at_least(:once)
    end

    it 'logs timestamp in ISO8601 format' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)).at_least(:once)
    end

    it 'logs controller name' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"controller":"supports"/)).at_least(:once)
    end

    it 'logs event type' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"event":"support_created"/)).at_least(:once)
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe 'authorization' do
    it 'prevents unauthenticated users from creating supports' do
      post :create, params: { proposal_id: proposal.id }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'prevents supporting finished proposals' do
      sign_in user
      allow(Proposal).to receive(:find).and_return(finished_proposal)
      allow(finished_proposal).to receive(:supportable?).and_return(false)
      post :create, params: { proposal_id: finished_proposal.id }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.cannot_support'))
    end

    it 'allows users to support active proposals' do
      sign_in user
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: proposal.id }
      expect(flash[:notice]).to eq(I18n.t('supports.created'))
    end
  end

  # ==================== INTEGRATION TESTS ====================

  describe 'integration with models' do
    before { sign_in user }

    it 'calls Proposal.find with correct id' do
      expect(Proposal).to receive(:find).with(proposal.id.to_s).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: proposal.id }
    end

    it 'calls supportable? on proposal' do
      allow(Proposal).to receive(:find).and_return(proposal)
      expect(proposal).to receive(:supportable?).with(user).and_return(true)
      post :create, params: { proposal_id: proposal.id }
    end

    it 'creates support through user association' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      expect(user.supports).to receive(:create!).with(proposal: proposal)
      post :create, params: { proposal_id: proposal.id }
    end

    it 'persists support to database' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: proposal.id }
      expect(Support.where(user: user, proposal: proposal).count).to eq(1)
    end
  end

  # ==================== ERROR HANDLING TESTS ====================

  describe 'error handling' do
    before { sign_in user }

    it 'handles nil proposal gracefully' do
      allow(Proposal).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      post :create, params: { proposal_id: 99_999 }
      expect(response).to be_redirect
      expect(flash[:alert]).to be_present
    end

    it 'handles database connection errors' do
      allow(Proposal).to receive(:find).and_raise(ActiveRecord::ConnectionNotEstablished)
      allow(Rails.logger).to receive(:error).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/support_creation_error/)).at_least(:once)
      expect(response).to redirect_to(proposals_path)
    end

    it 'handles validation errors' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:create!).and_raise(
        ActiveRecord::RecordInvalid.new(Support.new)
      )
      post :create, params: { proposal_id: proposal.id }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.support_failed'))
    end

    it 'logs full error details' do
      allow(Proposal).to receive(:find).and_raise(StandardError.new('Test error'))
      allow(Rails.logger).to receive(:error).and_call_original
      post :create, params: { proposal_id: proposal.id }
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/support_creation_error/)).at_least(:once)
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/StandardError/)).at_least(:once)
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/Test error/)).at_least(:once)
    end
  end

  # ==================== FLASH MESSAGE TESTS ====================

  describe 'flash messages' do
    before { sign_in user }

    it 'uses I18n for success message' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: proposal.id }
      expect(flash[:notice]).to eq(I18n.t('supports.created'))
    end

    it 'uses I18n for cannot_support message' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(false)
      post :create, params: { proposal_id: proposal.id }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.cannot_support'))
    end

    it 'uses I18n for not_found message' do
      post :create, params: { proposal_id: 99_999 }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.not_found'))
    end

    it 'uses I18n for support_failed message' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:create!).and_raise(
        ActiveRecord::RecordInvalid.new(Support.new)
      )
      post :create, params: { proposal_id: proposal.id }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.support_failed'))
    end

    it 'uses I18n for generic error message' do
      allow(Proposal).to receive(:find).and_raise(StandardError.new('Error'))
      post :create, params: { proposal_id: proposal.id }
      expect(flash[:alert]).to eq(I18n.t('errors.messages.generic'))
    end
  end

  # ==================== REQUEST PARAMETER TESTS ====================

  describe 'parameter handling' do
    before { sign_in user }

    it 'accepts numeric proposal_id' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: 123 }
      expect(response).to be_redirect
    end

    it 'accepts string proposal_id' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: '123' }
      expect(response).to be_redirect
    end

    it 'handles missing proposal_id parameter' do
      post :create, params: {}
      expect(response).to be_redirect
    end

    it 'handles invalid proposal_id format' do
      post :create, params: { proposal_id: 'invalid' }
      expect(response).to be_redirect
    end
  end

  # ==================== REDIRECT TESTS ====================

  describe 'redirects' do
    before { sign_in user }

    it 'redirects to proposal_path on success' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      post :create, params: { proposal_id: proposal.id }
      expect(response).to redirect_to(proposal_path(proposal))
    end

    it 'redirects to proposal_path on non-supportable' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(false)
      post :create, params: { proposal_id: proposal.id }
      expect(response).to redirect_to(proposal_path(proposal))
    end

    it 'redirects to proposals_path on not found' do
      post :create, params: { proposal_id: 99_999 }
      expect(response).to redirect_to(proposals_path)
    end

    it 'redirects to proposal_path on validation error' do
      allow(Proposal).to receive(:find).and_return(proposal)
      allow(proposal).to receive(:supportable?).and_return(true)
      allow_any_instance_of(ActiveRecord::Associations::CollectionProxy).to receive(:create!).and_raise(
        ActiveRecord::RecordInvalid.new(Support.new)
      )
      post :create, params: { proposal_id: proposal.id }
      expect(response).to redirect_to(proposal_path(proposal))
    end

    it 'redirects to proposals_path on general error' do
      allow(Proposal).to receive(:find).and_raise(StandardError.new('Error'))
      post :create, params: { proposal_id: proposal.id }
      expect(response).to redirect_to(proposals_path)
    end
  end
end
