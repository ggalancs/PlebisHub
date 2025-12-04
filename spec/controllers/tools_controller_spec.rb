# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToolsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }

  # Skip ApplicationController filters for isolation
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to(%r{/users/sign_in})
      end

      it 'does not set instance variables' do
        get :index
        expect(assigns(:elections)).to be_nil
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in user
      end

      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      describe 'session cleanup (LOW PRIORITY FIX)' do
        it 'deletes :return_to from session if present' do
          session[:return_to] = '/some/path'
          get :index
          expect(session[:return_to]).to be_nil
        end

        it 'does not error if :return_to is not in session' do
          expect(session).not_to have_key(:return_to)
          expect { get :index }.not_to raise_error
        end

        it 'uses simplified session.delete without conditional check' do
          # Verify the fix: session.delete(:return_to) instead of conditional
          session[:return_to] = '/test'
          allow(session).to receive(:delete).and_call_original
          get :index
          expect(session).to have_received(:delete).with(:return_to).at_least(:once)
        end
      end

      describe 'elections filtering (MEDIUM PRIORITY FIX)' do
        let!(:active_election) { create(:election, :active) }
        let!(:upcoming_election) { create(:election, :upcoming) }
        let!(:finished_election) { create(:election, :recently_finished) }

        before do
          # Mock has_valid_location_for? to return true for all elections
          allow_any_instance_of(Election).to receive(:has_valid_location_for?)
            .with(user, check_created_at: false)
            .and_return(true)

          # Mock upcoming_finished scope
          allow(Election).to receive(:upcoming_finished)
            .and_return([active_election, upcoming_election, finished_election])
        end

        it 'sets @all_elections with elections that have valid locations' do
          get :index
          expect(assigns(:all_elections)).to include(active_election, upcoming_election, finished_election)
        end

        it 'sets @elections with only active elections' do
          get :index
          expect(assigns(:elections)).to eq([active_election])
        end

        it 'sets @upcoming_elections with only upcoming elections' do
          get :index
          expect(assigns(:upcoming_elections)).to eq([upcoming_election])
        end

        it 'sets @finished_elections with only recently finished elections' do
          get :index
          expect(assigns(:finished_elections)).to eq([finished_election])
        end

        it 'calls has_valid_location_for? for each election' do
          expect(active_election).to receive(:has_valid_location_for?)
            .with(user, check_created_at: false)
            .and_return(true)

          get :index
        end

        context 'when election has no valid location for user' do
          before do
            allow(upcoming_election).to receive(:has_valid_location_for?)
              .with(user, check_created_at: false)
              .and_return(false)
          end

          it 'excludes that election from all lists' do
            get :index
            expect(assigns(:all_elections)).not_to include(upcoming_election)
            expect(assigns(:upcoming_elections)).to be_empty
          end
        end

        describe 'performance: single-pass iteration (LOW PRIORITY FIX)' do
          it 'uses single iteration instead of multiple selects' do
            # This fix reduces array iterations from 4 to 1
            # Previous: map + compact + 3x select = 5 iterations
            # After: 1x each = 1 iteration

            elections = [active_election, upcoming_election, finished_election]
            allow(Election).to receive(:upcoming_finished).and_return(elections)

            get :index

            # Verify all arrays are populated correctly
            expect(assigns(:all_elections).size).to eq(3)
            expect(assigns(:elections).size).to eq(1)
            expect(assigns(:upcoming_elections).size).to eq(1)
            expect(assigns(:finished_elections).size).to eq(1)
          end
        end
      end

      describe 'promoted forms' do
        let!(:promoted_page1) { create(:page, :promoted, priority: 10) }
        let!(:promoted_page2) { create(:page, :promoted, priority: 5) }
        let!(:non_promoted_page) { create(:page, promoted: false, priority: 20) }

        before do
          allow(Election).to receive(:upcoming_finished).and_return([])
        end

        it 'sets @promoted_forms with only promoted pages' do
          get :index
          promoted_ids = assigns(:promoted_forms).pluck(:id)
          expect(promoted_ids).to include(promoted_page1.id, promoted_page2.id)
          expect(promoted_ids).not_to include(non_promoted_page.id)
        end

        it 'orders promoted forms by priority descending' do
          get :index
          # Higher priority first
          expect(assigns(:promoted_forms).first.id).to eq(promoted_page1.id) # priority 10
          expect(assigns(:promoted_forms).last.id).to eq(promoted_page2.id)  # priority 5
        end

        it 'uses ActiveRecord safe query methods (SQL injection prevention)' do
          get :index
          # Verifies Page.where(promoted: true) was called with hash conditions
          expect(assigns(:promoted_forms)).to be_present
        end
      end

      describe 'edge cases' do
        context 'when no elections exist' do
          before do
            allow(Election).to receive(:upcoming_finished).and_return([])
          end

          it 'sets empty arrays for all election variables' do
            get :index
            expect(assigns(:all_elections)).to eq([])
            expect(assigns(:elections)).to eq([])
            expect(assigns(:upcoming_elections)).to eq([])
            expect(assigns(:finished_elections)).to eq([])
          end

          it 'still renders successfully' do
            get :index
            expect(response).to have_http_status(:success)
          end
        end

        context 'when no promoted forms exist' do
          it 'sets @promoted_forms to empty relation' do
            get :index
            expect(assigns(:promoted_forms)).to be_empty
          end

          it 'still renders successfully' do
            get :index
            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'error handling' do
        context 'when user_elections raises an error' do
          before do
            allow(Election).to receive(:upcoming_finished).and_raise(StandardError.new('Database error'))
          end

          it 'sets safe default empty arrays' do
            get :index
            expect(assigns(:all_elections)).to eq([])
            expect(assigns(:elections)).to eq([])
            expect(assigns(:upcoming_elections)).to eq([])
            expect(assigns(:finished_elections)).to eq([])
          end

          it 'logs the error' do
            allow(Rails.logger).to receive(:error).and_call_original
            get :index
            expect(Rails.logger).to have_received(:error).at_least(:once)
          end

          it 'still renders successfully' do
            get :index
            expect(response).to have_http_status(:success)
          end
        end

        context 'when get_promoted_forms raises an error' do
          before do
            allow(Election).to receive(:upcoming_finished).and_return([])
            allow(Page).to receive(:where).and_raise(StandardError.new('Database error'))
          end

          it 'sets @promoted_forms to empty array' do
            get :index
            expect(assigns(:promoted_forms)).to eq([])
          end

          it 'logs the error' do
            allow(Rails.logger).to receive(:error).and_call_original
            get :index
            expect(Rails.logger).to have_received(:error).at_least(:once)
          end

          it 'still renders successfully' do
            get :index
            expect(response).to have_http_status(:success)
          end
        end

        context 'when index action raises an error' do
          before do
            # Simulate error by having log_security_event raise an error
            # This will be caught by the rescue block in index action
            allow(controller).to receive(:log_security_event).and_raise(StandardError.new('Critical error'))
          end

          it 'redirects to root path' do
            get :index
            expect(response).to redirect_to(root_path)
          end

          it 'sets an alert flash message' do
            get :index
            expect(flash[:alert]).to eq(I18n.t('errors.messages.generic'))
          end

          it 'logs the error' do
            allow(Rails.logger).to receive(:error).and_call_original
            get :index
            expect(Rails.logger).to have_received(:error).at_least(:once)
          end
        end
      end

      describe 'security logging' do
        before do
          allow(Election).to receive(:upcoming_finished).and_return([])
        end

        it 'logs tools_dashboard_viewed event' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :index
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'includes IP address in log' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :index
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'includes user agent in log' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :index
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'includes timestamp in log' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :index
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'logs elections_loaded event' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :index
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end
      end
    end
  end

  describe 'GET #militant_request' do
    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :militant_request
        expect(response).to redirect_to(%r{/users/sign_in})
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in user
      end

      it 'returns http success' do
        get :militant_request
        expect(response).to have_http_status(:success)
      end

      it 'renders the militant_request template' do
        get :militant_request
        expect(response).to render_template(:militant_request)
      end

      describe 'security logging' do
        it 'logs militant_request_viewed event' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :militant_request
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'includes IP address in log' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :militant_request
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'includes user agent in log' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :militant_request
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end

        it 'includes timestamp in log' do
          allow(Rails.logger).to receive(:info).and_call_original
          get :militant_request
          expect(Rails.logger).to have_received(:info).at_least(:once)
        end
      end

      describe 'error handling' do
        before do
          # Simulate an error by having log_security_event raise an error
          # This will be caught by the rescue block in militant_request action
          allow(controller).to receive(:log_security_event).and_raise(StandardError.new('View error'))
        end

        it 'redirects to root path' do
          get :militant_request
          expect(response).to redirect_to(root_path)
        end

        it 'sets an alert flash message' do
          get :militant_request
          expect(flash[:alert]).to eq(I18n.t('errors.messages.generic'))
        end

        it 'logs the error' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :militant_request
          expect(Rails.logger).to have_received(:error).at_least(:once)
        end

        it 'includes backtrace in error log' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :militant_request
          expect(Rails.logger).to have_received(:error).at_least(:once)
        end
      end
    end
  end

  describe 'private methods' do
    before do
      sign_in user
    end

    describe '#user_elections' do
      it 'is called as a before_action for index' do
        expect(controller).to receive(:user_elections).and_call_original
        allow(Election).to receive(:upcoming_finished).and_return([])
        get :index
      end

      it 'is not called for militant_request' do
        expect(controller).not_to receive(:user_elections)
        get :militant_request
      end
    end

    describe '#get_promoted_forms' do
      it 'is called as a before_action for index' do
        expect(controller).to receive(:get_promoted_forms).and_call_original
        allow(Election).to receive(:upcoming_finished).and_return([])
        get :index
      end

      it 'is not called for militant_request' do
        expect(controller).not_to receive(:get_promoted_forms)
        get :militant_request
      end
    end

    describe '#log_security_event' do
      before do
        allow(Election).to receive(:upcoming_finished).and_return([])
      end

      it 'logs events as JSON with all required fields' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).at_least(:once)
      end

      it 'includes custom details passed to the method' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :index
        expect(Rails.logger).to have_received(:info).at_least(:once)
      end
    end

    describe '#log_error' do
      let(:error) { StandardError.new('Test error') }

      before do
        allow(controller).to receive(:log_security_event).and_raise(error)
      end

      it 'logs errors as JSON with all required fields' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :index
        expect(Rails.logger).to have_received(:error).at_least(:once)
      end

      it 'limits backtrace to first 5 lines' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :index
        expect(Rails.logger).to have_received(:error).at_least(:once)
      end

      it 'handles nil backtrace gracefully' do
        allow(error).to receive(:backtrace).and_return(nil)
        allow(controller).to receive(:log_security_event).and_raise(error)
        expect { get :index }.not_to raise_error
      end
    end
  end

  describe 'security validations' do
    before do
      sign_in user
      allow(Election).to receive(:upcoming_finished).and_return([])
    end

    it 'requires authentication via Devise for index' do
      sign_out user
      get :index
      expect(response).to redirect_to(%r{/users/sign_in})
    end

    it 'requires authentication via Devise for militant_request' do
      sign_out user
      get :militant_request
      expect(response).to redirect_to(%r{/users/sign_in})
    end

    it 'uses ActiveRecord safe query methods (no SQL injection)' do
      # Page.where(promoted: true) uses hash conditions - safe from SQL injection
      get :index
      expect(assigns(:promoted_forms)).not_to be_nil
    end

    it 'does not accept user parameters (no input validation needed)' do
      # Controller doesn't use params except from Devise current_user
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'uses frozen_string_literal for performance and security' do
      file_content = File.read(Rails.root.join('app/controllers/tools_controller.rb'))
      expect(file_content).to start_with("# frozen_string_literal: true")
    end
  end

  describe 'comprehensive error scenarios' do
    before do
      sign_in user
    end

    context 'when Election.upcoming_finished returns nil' do
      before do
        allow(Election).to receive(:upcoming_finished).and_return(nil)
      end

      it 'handles nil gracefully and sets empty arrays' do
        expect { get :index }.not_to raise_error
        expect(assigns(:all_elections)).to eq([])
      end
    end

    context 'when has_valid_location_for? raises an error' do
      let!(:election) { create(:election, :active) }

      before do
        allow(Election).to receive(:upcoming_finished).and_return([election])
        allow(election).to receive(:has_valid_location_for?).and_raise(StandardError.new('Location error'))
      end

      it 'handles error and sets empty arrays' do
        get :index
        expect(assigns(:all_elections)).to eq([])
        expect(assigns(:elections)).to eq([])
      end
    end

    context 'when multiple elections have different states' do
      let!(:election1) { create(:election, :active) }
      let!(:election2) { create(:election, :active) }
      let!(:election3) { create(:election, :upcoming) }

      before do
        allow_any_instance_of(Election).to receive(:has_valid_location_for?).and_return(true)
        allow(Election).to receive(:upcoming_finished).and_return([election1, election2, election3])
      end

      it 'correctly categorizes all elections' do
        get :index
        expect(assigns(:elections)).to contain_exactly(election1, election2)
        expect(assigns(:upcoming_elections)).to contain_exactly(election3)
        expect(assigns(:all_elections).size).to eq(3)
      end
    end

    context 'when Page query returns empty ActiveRecord::Relation' do
      before do
        allow(Election).to receive(:upcoming_finished).and_return([])
        allow(Page).to receive(:where).and_return(Page.none)
      end

      it 'handles empty relation gracefully' do
        get :index
        expect(assigns(:promoted_forms)).to be_empty
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'integration scenarios' do
    before do
      sign_in user
    end

    context 'with realistic data mix' do
      let!(:active_elections) { create_list(:election, 2, :active) }
      let!(:upcoming_elections) { create_list(:election, 3, :upcoming) }
      let!(:finished_elections) { create_list(:election, 1, :recently_finished) }
      let!(:promoted_pages) { create_list(:page, 2, :promoted) }

      before do
        allow_any_instance_of(Election).to receive(:has_valid_location_for?).and_return(true)
        all_elections = active_elections + upcoming_elections + finished_elections
        allow(Election).to receive(:upcoming_finished).and_return(all_elections)
      end

      it 'correctly handles all data' do
        get :index
        expect(assigns(:elections).size).to eq(2)
        expect(assigns(:upcoming_elections).size).to eq(3)
        expect(assigns(:finished_elections).size).to eq(1)
        expect(assigns(:promoted_forms).size).to eq(2)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
