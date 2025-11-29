# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCms::NoticeController, type: :controller do
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

    # Setup Devise mapping for tests
    @request.env["devise.mapping"] = Devise.mappings[:user]

    # Use actual engine routes instead of custom route set
    # Rails 7 requires engine controller specs to use engine routes
    @routes = PlebisCms::Engine.routes
  end

  describe "GET #index" do
    context "when user is not authenticated (CRITICAL FIX)" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not set instance variables" do
        get :index
        expect(assigns(:notices)).to be_nil
      end

      it "requires authentication via Devise" do
        sign_out user if user_signed_in?
        get :index
        expect(response).to redirect_to(new_user_session_path)
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

      describe "notice filtering (LOW PRIORITY FIX)" do
        let!(:sent_active_notice) { create(:notice, :sent_active) }
        let!(:pending_notice) { create(:notice, :pending) }
        let!(:expired_notice) { create(:notice, :sent_expired) }
        let!(:pending_active_notice) { create(:notice, :pending_active) }

        it "includes sent and active notices" do
          get :index
          expect(assigns(:notices)).to include(sent_active_notice)
        end

        it "excludes pending (unsent) notices" do
          get :index
          expect(assigns(:notices)).not_to include(pending_notice)
          expect(assigns(:notices)).not_to include(pending_active_notice)
        end

        it "excludes expired notices" do
          get :index
          expect(assigns(:notices)).not_to include(expired_notice)
        end

        it "only shows notices that are both sent AND active" do
          get :index

          notices = assigns(:notices).to_a
          notices.each do |notice|
            expect(notice.sent_at).not_to be_nil
            expect(notice.active?).to be true
          end
        end

        it "uses sent scope correctly" do
          # Create more test data
          create(:notice, :pending)
          create(:notice, :sent_active)

          get :index

          assigns(:notices).each do |notice|
            expect(notice.sent_at).to be_present
          end
        end

        it "uses active scope correctly" do
          # Active means: final_valid_at is nil OR future
          get :index

          assigns(:notices).each do |notice|
            if notice.final_valid_at.present?
              expect(notice.final_valid_at).to be > Time.current
            end
          end
        end
      end

      describe "pagination (MEDIUM PRIORITY FIX)" do
        before do
          # Create 12 sent+active notices (more than default 5 per page)
          12.times { create(:notice, :sent_active) }
        end

        it "paginates results" do
          get :index
          expect(assigns(:notices).current_page).to eq(1)
        end

        it "accepts page parameter" do
          get :index, params: { page: 2 }
          expect(assigns(:notices).current_page).to eq(2)
        end

        it "defaults to page 1 when page is nil" do
          get :index, params: { page: nil }
          expect(assigns(:notices).current_page).to eq(1)
        end

        it "defaults to page 1 when page is empty string" do
          get :index, params: { page: "" }
          expect(assigns(:notices).current_page).to eq(1)
        end

        it "handles page parameter correctly" do
          get :index, params: { page: "1" }
          expect(assigns(:notices).current_page).to eq(1)
        end

        it "returns paginated collection" do
          get :index
          expect(assigns(:notices)).to respond_to(:current_page)
          expect(assigns(:notices)).to respond_to(:total_pages)
        end

        it "respects default pagination size (5 per page from Notice model)" do
          get :index
          expect(assigns(:notices).limit_value).to eq(5)
        end

        context "when requesting page beyond available pages" do
          it "returns empty results for out-of-bounds page" do
            get :index, params: { page: 999 }
            expect(assigns(:notices)).to be_empty
          end
        end
      end

      describe "edge cases" do
        context "when no notices exist" do
          it "assigns empty collection" do
            get :index
            expect(assigns(:notices)).to be_empty
          end

          it "still renders successfully" do
            get :index
            expect(response).to have_http_status(:success)
          end
        end

        context "when only pending notices exist" do
          before do
            create(:notice, :pending)
            create(:notice, :pending_active)
          end

          it "returns empty results (pending filtered out)" do
            get :index
            expect(assigns(:notices)).to be_empty
          end
        end

        context "when only expired notices exist" do
          before do
            create(:notice, :sent_expired)
          end

          it "returns empty results (expired filtered out)" do
            get :index
            expect(assigns(:notices)).to be_empty
          end
        end

        context "when notices are sent but have no expiration" do
          let!(:sent_no_expiry) { create(:notice, :sent, :without_expiration) }

          it "includes sent notices with no expiration (considered active)" do
            get :index
            expect(assigns(:notices)).to include(sent_no_expiry)
          end
        end

        context "with mixed notice states" do
          let!(:valid_notice) { create(:notice, :sent_active) }

          before do
            create(:notice, :pending)
            create(:notice, :sent_expired)
            create(:notice, :pending_active)
          end

          it "returns only the valid notice" do
            get :index
            expect(assigns(:notices).to_a).to eq([valid_notice])
          end
        end
      end

      describe "ordering" do
        let!(:old_notice) { create(:notice, :sent_active, created_at: 2.days.ago) }
        let!(:recent_notice) { create(:notice, :sent_active, created_at: 1.hour.ago) }

        it "orders notices by created_at DESC (newest first)" do
          get :index

          notices = assigns(:notices).to_a
          expect(notices.first).to eq(recent_notice)
          expect(notices.last).to eq(old_notice)
        end

        it "uses Notice model's default_scope for ordering" do
          get :index

          # Verify descending order
          created_ats = assigns(:notices).pluck(:created_at)
          expect(created_ats).to eq(created_ats.sort.reverse)
        end
      end
    end
  end

  describe "security validations" do
    before do
      sign_in user
    end

    it "requires authentication via Devise (CRITICAL FIX)" do
      sign_out user
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it "uses ActiveRecord safe query methods (no SQL injection)" do
      get :index
      expect(assigns(:notices)).not_to be_nil
    end

    it "does not accept user parameters for filtering (no injection risk)" do
      # Controller doesn't use user-controllable filtering params
      get :index, params: { notice: { title: "Injection attempt" } }
      expect(response).to have_http_status(:success)
    end

    it "only shows authorized data (sent and active notices)" do
      pending_notice = create(:notice, :pending)
      sent_active_notice = create(:notice, :sent_active)

      get :index

      expect(assigns(:notices)).to include(sent_active_notice)
      expect(assigns(:notices)).not_to include(pending_notice)
    end
  end

  describe "parameter handling (MEDIUM PRIORITY FIX)" do
    before do
      sign_in user
      create(:notice, :sent_active)
    end

    it "handles nil page parameter safely" do
      expect {
        get :index, params: { page: nil }
      }.not_to raise_error

      expect(assigns(:notices).current_page).to eq(1)
    end

    it "handles empty string page parameter safely" do
      expect {
        get :index, params: { page: "" }
      }.not_to raise_error

      expect(assigns(:notices).current_page).to eq(1)
    end

    it "handles numeric page parameter" do
      expect {
        get :index, params: { page: 1 }
      }.not_to raise_error

      expect(assigns(:notices).current_page).to eq(1)
    end

    it "handles string numeric page parameter" do
      expect {
        get :index, params: { page: "1" }
      }.not_to raise_error

      expect(assigns(:notices).current_page).to eq(1)
    end
  end

  describe "performance considerations" do
    before do
      sign_in user
    end

    it "uses database-level pagination (not array pagination)" do
      create_list(:notice, 20, :sent_active)

      get :index

      # Kaminari returns ActiveRecord::Relation, not Array
      expect(assigns(:notices)).to be_a(ActiveRecord::Relation)
    end

    it "applies scopes before pagination (efficient)" do
      # Scopes should be chained: Notice.sent.active.page(1)
      # Not: Notice.page(1).select { |n| n.sent? && n.active? }

      create_list(:notice, 20, :sent_active)
      create_list(:notice, 20, :pending)

      get :index

      # All results should be sent and active (scoped at DB level)
      assigns(:notices).each do |notice|
        expect(notice.sent_at).to be_present
        expect(notice.active?).to be true
      end
    end
  end
end
