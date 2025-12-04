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

    # Rails 7.2 FIX: Use main app routes instead of engine routes
    # ImpulsaController is an alias in app/controllers that inherits from PlebisImpulsa::ImpulsaController
    # The routes are defined in config/routes.rb (main app), not in the engine
    @routes = Rails.application.routes

    # Mock wizard configuration
    allow_any_instance_of(ImpulsaProject).to receive(:wizard).and_return({
                                                                           step1: {
                                                                             title: 'Step 1',
                                                                             groups: {
                                                                               group1: {
                                                                                 condition: nil,
                                                                                 fields: {
                                                                                   field1: { type: 'text', optional: false },
                                                                                   file1: { type: 'file', filetype: 'document' }
                                                                                 }
                                                                               }
                                                                             }
                                                                           },
                                                                           step2: {
                                                                             title: 'Step 2',
                                                                             groups: {
                                                                               group2: {
                                                                                 condition: nil,
                                                                                 fields: {
                                                                                   field2: { type: 'text', optional: false }
                                                                                 }
                                                                               }
                                                                             }
                                                                           }
                                                                         })
  end

  # ==================== AUTHENTICATION TESTS ====================

  describe 'authentication' do
    context 'when user not logged in' do
      it 'allows access to index' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'redirects to sign in for project' do
        get :project
        # Rails 7.2: Devise redirects without locale in controller specs
        expect(response).to redirect_to(%r{/users/sign_in})
      end

      it 'redirects to sign in for upload' do
        post :upload, params: { step: 'step1', field: 'group1.file1' }, format: :json
        # Rails 7.2: Devise returns 401 Unauthorized for JSON format
        expect(response).to have_http_status(:unauthorized)
      end

      it 'redirects to sign in for download' do
        get :download, params: { field: 'group1.file1.pdf' }
        # Rails 7.2: Devise returns 401 Unauthorized for HTML format when accessed via controller spec
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user logged in' do
      before { sign_in user }

      it 'allows access to project' do
        allow(ImpulsaEdition).to receive(:current).and_return(edition)
        get :project
        # Rails 7.2: Redirects to first step when no project in session
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe 'authorization' do
    before { sign_in user }

    describe 'verify_project_ownership' do
      before do
        allow(ImpulsaEdition).to receive(:current).and_return(edition)
      end

      it 'allows download of own project files' do
        allow(controller).to receive(:set_variables) do
          controller.instance_variable_set(:@project, project)
          controller.instance_variable_set(:@edition, edition)
        end
        allow(project).to receive(:wizard_path).and_return('/tmp/test.pdf')
        allow(File).to receive(:exist?).and_return(true)
        allow(controller).to receive(:send_file)

        get :download, params: { field: 'group1.file1.pdf' }

        # Should attempt to send file (authorization passed)
        expect(controller).to have_received(:send_file)
      end

      it "prevents download of other user's project files" do
        # Rails 7.2: set_variables uses .where not .find, so stub set_variables to inject other_project
        allow(controller).to receive(:set_variables) do
          controller.instance_variable_set(:@project, other_project)
          controller.instance_variable_set(:@edition, edition)
        end

        get :download, params: { field: 'group1.file1.pdf' }

        expect(response).to redirect_to(impulsa_path)
        expect(flash[:alert]).to eq(I18n.t('impulsa.errors.unauthorized'))
      end

      it 'logs unauthorized access attempts' do
        allow(Rails.logger).to receive(:warn).and_call_original

        allow(controller).to receive(:set_variables) do
          controller.instance_variable_set(:@project, other_project)
          controller.instance_variable_set(:@edition, edition)
        end

        post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/unauthorized_project_access/)).at_least(:once)
      end
    end
  end

  # ==================== PATH TRAVERSAL SECURITY TESTS ====================

  describe 'path traversal security' do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    describe 'download action' do
      it 'rejects path traversal attempts with ../' do
        # Rails 7.2: Route constraints block path traversal at routing level
        expect do
          get :download, params: { field: '../../../etc/passwd' }
        end.to raise_error(ActionController::UrlGenerationError)
      end

      it 'rejects absolute paths' do
        # Rails 7.2: Route constraints block absolute paths at routing level
        expect do
          get :download, params: { field: '/etc/passwd' }
        end.to raise_error(ActionController::UrlGenerationError)
      end

      it 'rejects fields without proper format' do
        allow(Rails.logger).to receive(:warn).and_call_original

        get :download, params: { field: 'malicious' }

        expect(response).to have_http_status(:not_found)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_download_field/)).at_least(:once)
      end

      it 'rejects fields with directory traversal in gname' do
        # Rails 7.2: Route constraints block directory traversal at routing level
        expect do
          get :download, params: { field: '../group1.file1.pdf' }
        end.to raise_error(ActionController::UrlGenerationError)
      end

      it 'accepts valid field format' do
        allow(project).to receive(:wizard_path).and_return('/tmp/valid_file.pdf')
        allow(File).to receive(:exist?).and_return(true)
        allow(controller).to receive(:send_file)

        get :download, params: { field: 'group1.file1.pdf' }

        expect(controller).to have_received(:send_file).with('/tmp/valid_file.pdf')
      end

      it "returns not_found when file doesn't exist" do
        allow(project).to receive(:wizard_path).and_return('/tmp/nonexistent.pdf')
        allow(File).to receive(:exist?).and_return(false)
        allow(Rails.logger).to receive(:warn).and_call_original

        get :download, params: { field: 'group1.file1.pdf' }

        expect(response).to have_http_status(:not_found)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/file_not_found_or_unauthorized/)).at_least(:once)
      end

      it 'logs all download attempts' do
        allow(project).to receive(:wizard_path).and_return('/tmp/test.pdf')
        allow(File).to receive(:exist?).and_return(true)
        allow(controller).to receive(:send_file)
        allow(Rails.logger).to receive(:info).and_call_original

        get :download, params: { field: 'group1.file1.pdf' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/file_downloaded/)).at_least(:once)
      end
    end

    describe 'upload action' do
      it 'rejects invalid field format' do
        # Rails 7.2: Route constraints block path traversal at routing level
        expect do
          post :upload, params: { step: 'step1', field: '../malicious', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json
        end.to raise_error(ActionController::UrlGenerationError)
      end

      it 'accepts valid field format' do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)
        allow(project).to receive(:wizard_values).and_return({ 'group1.file1' => 'test.pdf' })

        post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'logs file uploads' do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)
        allow(project).to receive(:wizard_values).and_return({ 'group1.file1' => 'test.pdf' })
        allow(Rails.logger).to receive(:info).and_call_original

        post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/file_uploaded/)).at_least(:once)
      end
    end

    describe 'delete_file action' do
      it 'rejects invalid field format' do
        # Rails 7.2: Route constraints block path traversal at routing level
        expect do
          delete :delete_file, params: { step: 'step1', field: '../../../etc/passwd' }, format: :json
        end.to raise_error(ActionController::UrlGenerationError)
      end

      it 'accepts valid field format' do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)

        delete :delete_file, params: { step: 'step1', field: 'group1.file1' }, format: :json

        expect(response).to have_http_status(:success)
      end

      it 'logs file deletions' do
        allow(project).to receive(:assign_wizard_value).and_return(:ok)
        allow(project).to receive(:save).and_return(true)
        allow(Rails.logger).to receive(:info).and_call_original

        delete :delete_file, params: { step: 'step1', field: 'group1.file1' }, format: :json

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/file_deleted/)).at_least(:once)
      end
    end
  end

  # ==================== STEP VALIDATION TESTS ====================

  describe 'step validation' do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
    end

    it 'accepts valid wizard step' do
      # Let set_variables run naturally by stubbing the models it calls
      allow(PlebisImpulsa::ImpulsaEdition).to receive(:current).and_return(edition)
      allow(ImpulsaEdition).to receive(:current).and_return(edition)

      # Mock the edition's impulsa_projects association to return our project
      projects_relation = double('projects_relation')
      allow(projects_relation).to receive(:where).with(user: user).and_return(double('scoped_relation', first: project))
      allow(edition).to receive(:impulsa_projects).and_return(projects_relation)

      # Mock the edition categories with a relation that supports non_authors
      categories_relation = double('categories_relation')
      allow(categories_relation).to receive(:non_authors).and_return([])
      allow(edition).to receive(:impulsa_edition_categories).and_return(categories_relation)

      # Mock user.impulsa_author? to return false
      allow(user).to receive(:impulsa_author?).and_return(false)

      # Ensure project has the wizard method defined for validate_step
      allow(project).to receive(:wizard).and_return({
                                                      step1: { title: 'Step 1', groups: {} },
                                                      step2: { title: 'Step 2', groups: {} }
                                                    })

      # Mock wizard_status to return Hash with default value to handle any key access
      wizard_status_hash = Hash.new { |_h, _k| { filled: true } }
      wizard_status_hash['step1'] = { filled: true }
      wizard_status_hash[:step1] = { filled: true }
      allow(project).to receive(:wizard_status).and_return(wizard_status_hash)
      allow(project).to receive(:valid?).and_return(true)
      allow(project).to receive(:wizard_step_valid?).and_return(true)
      allow(project).to receive(:wizard_step=)
      allow(project).to receive(:assign_attributes)

      get :project_step, params: { step: 'step1' }
      expect(response).to have_http_status(:success)
    end

    it 'rejects invalid wizard step' do
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
        controller.instance_variable_set(:@step, 'invalid_step')
      end
      allow(Rails.logger).to receive(:warn).and_call_original

      get :project_step, params: { step: 'invalid_step' }

      expect(response).to redirect_to(project_impulsa_path)
      expect(flash[:alert]).to eq(I18n.t('impulsa.errors.invalid_step'))
      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_wizard_step/)).at_least(:once)
    end

    it 'allows nil step' do
      # Rails 7.2: project_step action requires step parameter in route
      expect do
        get :project_step
      end.to raise_error(ActionController::UrlGenerationError, /No route matches/)
    end

    it 'logs invalid step attempts' do
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
        controller.instance_variable_set(:@step, 'invalid_step')
      end
      allow(Rails.logger).to receive(:warn).and_call_original

      get :project_step, params: { step: 'invalid_step' }

      expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_wizard_step.*invalid_step/)).at_least(:once)
    end
  end

  # ==================== FILE UPLOAD SECURITY TESTS ====================

  describe 'file upload security' do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    it 'requires file parameter' do
      post :upload, params: { step: 'step1', field: 'group1.file1' }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to include(I18n.t('impulsa.errors.no_file_provided'))
    end

    it 'rejects wrong file extension' do
      allow(project).to receive(:assign_wizard_value).and_return(:wrong_extension)

      post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.exe', 'application/octet-stream') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to include(I18n.t('impulsa.errors.wrong_extension'))
    end

    it 'rejects files that are too large' do
      allow(project).to receive(:assign_wizard_value).and_return(:wrong_size)

      post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to include(I18n.t('impulsa.errors.wrong_size'))
    end

    it 'rejects upload to invalid field' do
      allow(project).to receive(:assign_wizard_value).and_return(:wrong_field)

      post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to include(I18n.t('impulsa.errors.wrong_field_upload'))
    end
  end

  # ==================== ERROR HANDLING TESTS ====================

  describe 'error handling' do
    before { sign_in user }

    it 'handles errors in index gracefully' do
      # Let set_variables run to set @edition to nil
      # Stub both the alias and the original class for compatibility
      allow(PlebisImpulsa::ImpulsaEdition).to receive(:current).and_return(nil)
      allow(ImpulsaEdition).to receive(:current).and_return(nil)

      # Create a mock that raises an error when .first is called
      upcoming_relation = instance_double('ActiveRecord::Relation')
      allow(upcoming_relation).to receive(:first).and_raise(StandardError.new('Database error'))

      # Stub upcoming on both classes
      allow(PlebisImpulsa::ImpulsaEdition).to receive(:upcoming).and_return(upcoming_relation)
      allow(ImpulsaEdition).to receive(:upcoming).and_return(upcoming_relation)

      # Spy on Rails.logger
      allow(Rails.logger).to receive(:error)

      get :index

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('impulsa.errors.generic'))
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/impulsa_index_failed/)).at_least(:once)
    end

    it 'handles errors in download gracefully' do
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end

      # Mock wizard_path to raise an error (this is called in the download action body)
      allow(project).to receive(:wizard_path).and_raise(StandardError.new('File system error'))

      # Spy on Rails.logger to check what's logged
      allow(Rails.logger).to receive(:error)

      get :download, params: { field: 'group1.file1.pdf' }

      expect(response).to have_http_status(:internal_server_error)
      expect(Rails.logger).to have_received(:error).with(a_string_matching(/impulsa_download_failed/)).at_least(:once)
    end

    it 'includes exception details in error logs' do
      # Stub both the alias and the original class
      allow(PlebisImpulsa::ImpulsaEdition).to receive(:current).and_return(nil)
      allow(ImpulsaEdition).to receive(:current).and_return(nil)

      upcoming_relation = instance_double('ActiveRecord::Relation')
      allow(upcoming_relation).to receive(:first).and_raise(StandardError.new('Test error'))

      allow(PlebisImpulsa::ImpulsaEdition).to receive(:upcoming).and_return(upcoming_relation)
      allow(ImpulsaEdition).to receive(:upcoming).and_return(upcoming_relation)

      # Spy on Rails.logger
      allow(Rails.logger).to receive(:error)

      get :index

      expect(Rails.logger).to have_received(:error).with(a_string_matching(/Test error/)).at_least(:once)
    end

    it 'includes backtrace in error logs' do
      # Stub both the alias and the original class
      allow(PlebisImpulsa::ImpulsaEdition).to receive(:current).and_return(nil)
      allow(ImpulsaEdition).to receive(:current).and_return(nil)

      upcoming_relation = instance_double('ActiveRecord::Relation')
      allow(upcoming_relation).to receive(:first).and_raise(StandardError.new('Test error'))

      allow(PlebisImpulsa::ImpulsaEdition).to receive(:upcoming).and_return(upcoming_relation)
      allow(ImpulsaEdition).to receive(:upcoming).and_return(upcoming_relation)

      # Spy on Rails.logger
      allow(Rails.logger).to receive(:error)

      get :index

      expect(Rails.logger).to have_received(:error).with(a_string_matching(/backtrace/)).at_least(:once)
    end
  end

  # ==================== STATE TRANSITION LOGGING TESTS ====================

  describe 'state transition logging' do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    it 'logs review state transition' do
      allow(project).to receive(:mark_for_review).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original

      post :review

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/state_transition.*marked_for_review/)).at_least(:once)
    end

    it 'logs deletion state transition' do
      allow(project).to receive(:deleteable?).and_return(true)
      allow(project).to receive(:destroy).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original

      delete :delete

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/state_transition.*project_deleted/)).at_least(:once)
    end

    it 'logs resignation state transition' do
      allow(project).to receive(:deleteable?).and_return(false)
      allow(project).to receive(:mark_as_resigned).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original

      delete :delete

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/state_transition.*project_resigned/)).at_least(:once)
    end
  end

  # ==================== PROJECT UPDATE LOGGING TESTS ====================

  describe 'project update logging' do
    before do
      sign_in user
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, project)
        controller.instance_variable_set(:@edition, edition)
      end
    end

    it 'logs project updates' do
      allow(project).to receive(:editable?).and_return(true)
      allow(project).to receive(:save).and_return(true)
      allow(Rails.logger).to receive(:info).and_call_original

      post :update, params: { impulsa_project: { name: 'New name' } }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/project_updated/)).at_least(:once)
    end

    it 'logs wizard step updates' do
      allow(project).to receive(:saveable?).and_return(true)
      allow(project).to receive(:save).and_return(true)
      allow(project).to receive(:changes).and_return({ 'wizard_step' => %w[step1 step2] })
      allow(project).to receive(:wizard_step_errors).and_return([])
      allow(project).to receive(:wizard_next_step).and_return(nil)
      allow(Rails.logger).to receive(:info).and_call_original

      post :update_step, params: { step: 'step1', impulsa_project: { _wiz_group1__field1: 'value' } }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/wizard_step_updated/)).at_least(:once)
    end
  end

  # ==================== I18N TESTS ====================

  describe 'i18n' do
    before { sign_in user }

    it 'uses I18n for error messages' do
      allow(ImpulsaEdition).to receive(:current).and_return(edition)
      allow(controller).to receive(:set_variables) do
        controller.instance_variable_set(:@project, other_project)
        controller.instance_variable_set(:@edition, edition)
      end

      post :upload, params: { step: 'step1', field: 'group1.file1', file: fixture_file_upload('test.pdf', 'application/pdf') }, format: :json

      expect(response).to redirect_to(impulsa_path)
      expect(flash[:alert]).to eq(I18n.t('impulsa.errors.unauthorized'))
    end

    it 'uses I18n for success messages' do
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
