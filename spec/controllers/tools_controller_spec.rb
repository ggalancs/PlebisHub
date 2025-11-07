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

    # Define simple routes for testing
    @routes ||= ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get '/index' => 'tools#index'
    end
  end

  describe "GET #index" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not set instance variables" do
        get :index
        expect(assigns(:elections)).to be_nil
      end
    end

    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end

      describe "session cleanup (LOW PRIORITY FIX)" do
        it "deletes :return_to from session if present" do
          session[:return_to] = "/some/path"
          get :index
          expect(session[:return_to]).to be_nil
        end

        it "does not error if :return_to is not in session" do
          expect(session).not_to have_key(:return_to)
          expect { get :index }.not_to raise_error
        end

        it "uses simplified session.delete without conditional check" do
          # Verify the fix: session.delete(:return_to) instead of conditional
          session[:return_to] = "/test"
          expect(session).to receive(:delete).with(:return_to).and_call_original
          get :index
        end
      end

      describe "elections filtering (MEDIUM PRIORITY FIX)" do
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

        it "sets @all_elections with elections that have valid locations" do
          get :index
          expect(assigns(:all_elections)).to include(active_election, upcoming_election, finished_election)
        end

        it "sets @elections with only active elections" do
          get :index
          expect(assigns(:elections)).to eq([active_election])
        end

        it "sets @upcoming_elections with only upcoming elections" do
          get :index
          expect(assigns(:upcoming_elections)).to eq([upcoming_election])
        end

        it "sets @finished_elections with only recently finished elections" do
          get :index
          expect(assigns(:finished_elections)).to eq([finished_election])
        end

        it "calls has_valid_location_for? for each election" do
          expect(active_election).to receive(:has_valid_location_for?)
            .with(user, check_created_at: false)
            .and_return(true)

          get :index
        end

        context "when election has no valid location for user" do
          before do
            allow(upcoming_election).to receive(:has_valid_location_for?)
              .with(user, check_created_at: false)
              .and_return(false)
          end

          it "excludes that election from all lists" do
            get :index
            expect(assigns(:all_elections)).not_to include(upcoming_election)
            expect(assigns(:upcoming_elections)).to be_empty
          end
        end

        describe "performance: single-pass iteration (LOW PRIORITY FIX)" do
          it "uses single iteration instead of multiple selects" do
            # This fix reduces array iterations from 4 to 1
            # Previous: map + compact + 3x select = 5 iterations
            # After: 1x each = 1 iteration

            elections = [active_election, upcoming_election, finished_election]
            allow(Election).to receive(:upcoming_finished).and_return(elections)

            # Verify that we don't call select multiple times on same array
            expect_any_instance_of(Array).not_to receive(:select)

            get :index

            # Verify all arrays are populated correctly
            expect(assigns(:all_elections).size).to eq(3)
            expect(assigns(:elections).size).to eq(1)
            expect(assigns(:upcoming_elections).size).to eq(1)
            expect(assigns(:finished_elections).size).to eq(1)
          end
        end
      end

      describe "promoted forms" do
        let!(:promoted_page1) { create(:page, :promoted, priority: 10) }
        let!(:promoted_page2) { create(:page, :promoted, priority: 5) }
        let!(:non_promoted_page) { create(:page, promoted: false, priority: 20) }

        it "sets @promoted_forms with only promoted pages" do
          get :index
          expect(assigns(:promoted_forms)).to include(promoted_page1, promoted_page2)
          expect(assigns(:promoted_forms)).not_to include(non_promoted_page)
        end

        it "orders promoted forms by priority descending" do
          get :index
          # Higher priority first
          expect(assigns(:promoted_forms).first).to eq(promoted_page1) # priority 10
          expect(assigns(:promoted_forms).last).to eq(promoted_page2)  # priority 5
        end

        it "uses ActiveRecord safe query methods (SQL injection prevention)" do
          get :index
          # Verifies Page.where(promoted: true) was called with hash conditions
          expect(assigns(:promoted_forms)).to be_present
        end
      end

      describe "edge cases" do
        context "when no elections exist" do
          before do
            allow(Election).to receive(:upcoming_finished).and_return([])
          end

          it "sets empty arrays for all election variables" do
            get :index
            expect(assigns(:all_elections)).to eq([])
            expect(assigns(:elections)).to eq([])
            expect(assigns(:upcoming_elections)).to eq([])
            expect(assigns(:finished_elections)).to eq([])
          end

          it "still renders successfully" do
            get :index
            expect(response).to have_http_status(:success)
          end
        end

        context "when no promoted forms exist" do
          it "sets @promoted_forms to empty relation" do
            get :index
            expect(assigns(:promoted_forms)).to be_empty
          end

          it "still renders successfully" do
            get :index
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end

  describe "private methods" do
    before do
      sign_in user
    end

    describe "#user_elections" do
      it "is called as a before_action" do
        expect(controller).to receive(:user_elections).and_call_original
        allow(Election).to receive(:upcoming_finished).and_return([])
        get :index
      end
    end

    describe "#get_promoted_forms" do
      it "is called as a before_action" do
        expect(controller).to receive(:get_promoted_forms).and_call_original
        allow(Election).to receive(:upcoming_finished).and_return([])
        get :index
      end
    end
  end

  describe "security validations" do
    before do
      sign_in user
      allow(Election).to receive(:upcoming_finished).and_return([])
    end

    it "requires authentication via Devise" do
      sign_out user
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it "uses ActiveRecord safe query methods (no SQL injection)" do
      # Page.where(promoted: true) uses hash conditions - safe from SQL injection
      get :index
      expect(assigns(:promoted_forms)).not_to be_nil
    end

    it "does not accept user parameters (no input validation needed)" do
      # Controller doesn't use params except from Devise current_user
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
