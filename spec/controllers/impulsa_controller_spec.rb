# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:other_user) { create(:user, confirmed_at: Time.current) }
  let(:edition) { create(:impulsa_edition, :current) }
  let(:category) { create(:impulsa_edition_category, impulsa_edition: edition) }
  let(:project) { create(:impulsa_project, user: user, impulsa_edition_category: category) }
  let(:other_project) { create(:impulsa_project, user: other_user, impulsa_edition_category: category) }

  before do
    # Skip ApplicationController filters for isolation
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Mock wizard configuration
    allow_any_instance_of(ImpulsaProject).to receive(:wizard).and_return({
      step1: {
        title: "Step 1",
        groups: {
          group1: {
            condition: nil,
            fields: {
              field1: { type: "text", optional: false },
              file1: { type: "file", filetype: "document" }
            }
          }
        }
      },
      step2: {
        title: "Step 2",
        groups: {
          group2: {
            condition: nil,
            fields: {
              field2: { type: "text", optional: false }
            }
          }
        }
      }
    })
  end

  # ==================== AUTHENTICATION TESTS ====================

  describe "authentication" do
    context "when user not logged in" do
      it "allows access to index" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "redirects to sign in for project" do
        get :project
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to sign in for upload" do
        post :upload, params: { field: "group1.file1" }, format: :json
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to sign in for download" do
        get :download, params: { field: "group1.file1.pdf" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user logged in" do
      before { sign_in user }

      it "allows access to project" do
        allow(ImpulsaEdition).to receive(:current).and_return(edition)
        get :project
        expect(response).to have_http_status(:success)
      end
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe "authorization" do
    before { sign_in user }

    describe "verify_project_ownership" do
      before do
        allow(ImpulsaEdition).to receive(:current).and_return(edition)
      end

      it "allows download of own project files" do
        allow(project).to receive(:wizard_path).and_return("/tmp/test.pdf")
        allow(File).to receive(:exist?).and_return(true)
        allow(controller).to receive(:send_file)

        get :download, params: { field: "group1.file1.pdf" }, session: { project_id: project.id }

        # Should attempt to send file (authorization passed)
        expect(controller).to have_received(:send_file)
      end

      it "prevents download of other user's project files" do
        allow(ImpulsaProject).to receive(:find).and_return(other_project)

        get :download, params: { field: "group1.file1.pdf" }

        expect(response).to redirect_to(impulsa_path)
        expect(flash[:alert]).to eq(I18n.t('impulsa.errors.unauthorized'))
      end

      it "logs unauthorized access attempts" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/unauthorized_project_access/))

        allow(controller).to receive(:set_variables) do
          controller.instance_variable_set(:@project, other_project)
          controller.instance_variable_set(:@edition, edition)
        end

        post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json
      end
    end
  end

  # ==================== PATH TRAVERSAL SECURITY TESTS ====================

  describe "path traversal security" do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    describe "download action" do
      it "rejects path traversal attempts with ../" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_download_field/))

        get :download, params: { field: "../../../etc/passwd" }

        expect(response).to have_http_status(:not_found)
      end

      it "rejects absolute paths" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_download_field/))

        get :download, params: { field: "/etc/passwd" }

        expect(response).to have_http_status(:not_found)
      end

      it "rejects fields without proper format" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_download_field/))

        get :download, params: { field: "malicious" }

        expect(response).to have_http_status(:not_found)
      end

      it "rejects fields with directory traversal in gname" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_download_field/))

        get :download, params: { field: "../group1.file1.pdf" }

        expect(response).to have_http_status(:not_found)
      end

      it "accepts valid field format" do
        allow(project).to receive(:wizard_path).and_return("/tmp/valid_file.pdf")
        allow(File).to receive(:exist?).and_return(true)
        allow(controller).to receive(:send_file)

        get :download, params: { field: "group1.file1.pdf" }

        expect(controller).to have_received(:send_file).with("/tmp/valid_file.pdf")
      end

      it "returns not_found when file doesn't exist" do
        allow(project).to receive(:wizard_path).and_return("/tmp/nonexistent.pdf")
        allow(File).to receive(:exist?).and_return(false)

        expect(Rails.logger).to receive(:warn).with(a_string_matching(/file_not_found_or_unauthorized/))

        get :download, params: { field: "group1.file1.pdf" }

        expect(response).to have_http_status(:not_found)
      end

      it "logs all download attempts" do
        allow(project).to receive(:wizard_path).and_return("/tmp/test.pdf")
        allow(File).to receive(:exist?).and_return(true)
        allow(controller).to receive(:send_file)

        expect(Rails.logger).to receive(:info).with(a_string_matching(/file_downloaded/))

        get :download, params: { field: "group1.file1.pdf" }
      end
    end

    describe "upload action" do
      it "rejects invalid field format" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_upload_field/))

        post :upload, params: { field: "../malicious", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(I18n.t('impulsa.errors.invalid_field'))
      end

      it "accepts valid field format" do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)
        allow(project).to receive(:wizard_values).and_return({ "group1.file1" => "test.pdf" })

        post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

        expect(response).to have_http_status(:success)
      end

      it "logs file uploads" do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)
        allow(project).to receive(:wizard_values).and_return({ "group1.file1" => "test.pdf" })

        expect(Rails.logger).to receive(:info).with(a_string_matching(/file_uploaded/))

        post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json
      end
    end

    describe "delete_file action" do
      it "rejects invalid field format" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_delete_field/))

        delete :delete_file, params: { field: "../../../etc/passwd" }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "accepts valid field format" do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)

        delete :delete_file, params: { field: "group1.file1" }, format: :json

        expect(response).to have_http_status(:success)
      end

      it "logs file deletions" do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)

        expect(Rails.logger).to receive(:info).with(a_string_matching(/file_deleted/))

        delete :delete_file, params: { field: "group1.file1" }, format: :json
      end
    end
  end

  # ==================== STEP VALIDATION TESTS ====================

  describe "step validation" do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
        controller.instance_variable_set(:@step, params[:step])
      end
    end

    it "accepts valid wizard step" do
      get :project_step, params: { step: "step1" }
      expect(response).to have_http_status(:success)
    end

    it "rejects invalid wizard step" do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_wizard_step/))

      get :project_step, params: { step: "invalid_step" }

      expect(response).to redirect_to(project_impulsa_path)
      expect(flash[:alert]).to eq(I18n.t('impulsa.errors.invalid_step'))
    end

    it "allows nil step" do
      get :project_step
      expect(response).to have_http_status(:success)
    end

    it "logs invalid step attempts" do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_wizard_step.*invalid_step/))

      get :project_step, params: { step: "invalid_step" }
    end
  end

  # ==================== FILE UPLOAD SECURITY TESTS ====================

  describe "file upload security" do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    it "requires file parameter" do
      post :upload, params: { field: "group1.file1" }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include(I18n.t('impulsa.errors.no_file_provided'))
    end

    it "rejects wrong file extension" do
      allow(project).to receive(:assign_wizard_value).and_return(:wrong_extension)

      post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.exe', 'application/octet-stream') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include(I18n.t('impulsa.errors.wrong_extension'))
    end

    it "rejects files that are too large" do
      allow(project).to receive(:assign_wizard_value).and_return(:wrong_size)

      post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include(I18n.t('impulsa.errors.wrong_size'))
    end

    it "rejects upload to invalid field" do
      allow(project).to receive(:assign_wizard_value).and_return(:wrong_field)

      post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to include(I18n.t('impulsa.errors.wrong_field_upload'))
    end
  end

  # ==================== ERROR HANDLING TESTS ====================

  describe "error handling" do
    before { sign_in user }

    it "handles errors in index gracefully" do
      allow(ImpulsaEdition).to receive(:current).and_raise(StandardError.new("Database error"))

      expect(Rails.logger).to receive(:error).with(a_string_matching(/impulsa_index_failed/))

      get :index

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('impulsa.errors.generic'))
    end

    it "handles errors in download gracefully" do
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        raise StandardError.new("File system error")
      end

      expect(Rails.logger).to receive(:error).with(a_string_matching(/impulsa_download_failed/))

      get :download, params: { field: "group1.file1.pdf" }

      expect(response).to have_http_status(:internal_server_error)
    end

    it "includes exception details in error logs" do
      allow(ImpulsaEdition).to receive(:current).and_raise(StandardError.new("Test error"))

      expect(Rails.logger).to receive(:error).with(a_string_matching(/Test error/))

      get :index
    end

    it "includes backtrace in error logs" do
      allow(ImpulsaEdition).to receive(:current).and_raise(StandardError.new("Test error"))

      expect(Rails.logger).to receive(:error).with(a_string_matching(/backtrace/))

      get :index
    end
  end

  # ==================== STATE TRANSITION LOGGING TESTS ====================

  describe "state transition logging" do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    it "logs review state transition" do
      allow(project).to receive(:mark_for_review).and_return(true)

      expect(Rails.logger).to receive(:info).with(a_string_matching(/state_transition.*marked_for_review/))

      post :review
    end

    it "logs deletion state transition" do
      allow(project).to receive(:deleteable?).and_return(true)
      allow(project).to receive(:destroy).and_return(true)

      expect(Rails.logger).to receive(:info).with(a_string_matching(/state_transition.*project_deleted/))

      delete :delete
    end

    it "logs resignation state transition" do
      allow(project).to receive(:deleteable?).and_return(false)
      allow(project).to receive(:mark_as_resigned).and_return(true)

      expect(Rails.logger).to receive(:info).with(a_string_matching(/state_transition.*project_resigned/))

      delete :delete
    end
  end

  # ==================== PROJECT UPDATE LOGGING TESTS ====================

  describe "project update logging" do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    it "logs project updates" do
      allow(project).to receive(:editable?).and_return(true)
      allow(project).to receive(:save).and_return(true)

      expect(Rails.logger).to receive(:info).with(a_string_matching(/project_updated/))

      post :update, params: { impulsa_project: { name: "New name" } }
    end

    it "logs wizard step updates" do
      allow(project).to receive(:saveable?).and_return(true)
      allow(project).to receive(:save).and_return(true)
      allow(project).to receive(:changes).and_return({ "wizard_step" => ["step1", "step2"] })
      allow(project).to receive(:wizard_step_errors).and_return([])
      allow(project).to receive(:wizard_next_step).and_return(nil)

      expect(Rails.logger).to receive(:info).with(a_string_matching(/wizard_step_updated/))

      post :update_step, params: { impulsa_project: { _wiz_group1__field1: "value" } }
    end
  end

  # ==================== I18N TESTS ====================

  describe "i18n" do
    before { sign_in user }

    it "uses I18n for error messages" do
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, other_project)
        controller.instance_variable_set(:@edition, edition)
      end

      post :upload, params: { field: "group1.file1", file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

      expect(response).to redirect_to(impulsa_path)
      expect(flash[:alert]).to eq(I18n.t('impulsa.errors.unauthorized'))
    end

    it "uses I18n for success messages" do
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
      allow(project).to receive(:mark_for_review).and_return(true)

      post :review

      expect(flash[:notice]).to eq(I18n.t('impulsa.messages.marked_for_review'))
    end
  end
end
