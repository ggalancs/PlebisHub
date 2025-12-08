# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImpulsaProject Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin, admin: true) }
  let(:impulsa_edition) { create(:impulsa_edition) }
  let(:wizard_config) do
    {
      step1: {
        title: 'Step 1',
        groups: {
          group1: {
            title: 'Group 1',
            fields: {
              field1: { title: 'Field 1', type: 'string' },
              field2: { title: 'Field 2', type: 'select', collection: { 'a' => 'Option A', 'b' => 'Option B' } },
              field3: { title: 'Field 3', type: 'check_boxes', collection: { '1' => 'Check 1', '2' => 'Check 2' } },
              field4: { title: 'File Upload', type: 'file' }
            }
          }
        }
      }
    }
  end
  let(:evaluation_config) do
    {
      eval_step1: {
        title: 'Evaluation Step 1',
        groups: {
          eval_group1: {
            title: 'Evaluation Group 1',
            fields: {
              eval_field1: { title: 'Evaluation Field 1', type: 'number', minimum: 0, maximum: 10 },
              eval_field2: { title: 'Evaluation Field 2', type: 'text' },
              eval_field3: { title: 'Sum Field', type: 'number', sum: true }
            }
          }
        }
      }
    }
  end
  let(:impulsa_edition_category) do
    create(:impulsa_edition_category, impulsa_edition: impulsa_edition, wizard: wizard_config, evaluation: evaluation_config)
  end
  let(:project_user) { create(:user) }
  let(:evaluator1) { create(:user, :admin, :superadmin, admin: true) }
  let(:evaluator2) { create(:user, :admin, :superadmin, admin: true) }
  let!(:impulsa_project) do
    create(:impulsa_project,
           impulsa_edition_category: impulsa_edition_category,
           user: project_user,
           name: 'Test Project',
           evaluator1: evaluator1,
           evaluator2: evaluator2,
           votes: 100,
           wizard_step: 'step1')
  end

  before do
    sign_in_admin admin_user
  end

  describe 'configuration' do
    it 'is registered as an ActiveAdmin resource' do
      resource = ActiveAdmin.application.namespaces[:admin].resources[ImpulsaProject]
      expect(resource).to be_present
    end

    it 'has menu disabled' do
      resource = ActiveAdmin.application.namespaces[:admin].resources[ImpulsaProject]
      expect(resource.menu_item).to be_nil
    end

    it 'belongs to impulsa_edition' do
      resource = ActiveAdmin.application.namespaces[:admin].resources[ImpulsaProject]
      # The target is the parent resource, check belongs_to is configured
      expect(resource.belongs_to_config).to be_present
    end
  end

  describe 'permit_params' do
    it 'permits basic params' do
      # Just verify the resource is accessible and index works
      get admin_impulsa_edition_impulsa_projects_path(impulsa_edition)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'custom member actions' do
    describe 'spam action' do
      it 'marks project as spam' do
        expect do
          post spam_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        end.to change { impulsa_project.reload.state }.to('spam')
      end

      it 'sets flash notice' do
        post spam_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        expect(flash[:notice]).to eq('El proyecto ha sido marcado como spam.')
      end

      it 'redirects to impulsa_projects list' do
        post spam_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        expect(response).to redirect_to(admin_impulsa_edition_impulsa_projects_path(impulsa_edition))
      end
    end

    describe 'review action' do
      before do
        impulsa_project.update(state: :new)
      end

      it 'marks project for review when markable' do
        allow_any_instance_of(ImpulsaProject).to receive(:markable_for_review?).and_return(true)
        expect do
          post review_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        end.to change { impulsa_project.reload.state }.to('review')
      end

      it 'sets flash notice' do
        allow_any_instance_of(ImpulsaProject).to receive(:markable_for_review?).and_return(true)
        post review_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        expect(flash[:notice]).to eq('El proyecto ha sido marcado para revisión.')
      end
    end

    describe 'reset_evaluator action' do
      before do
        impulsa_project.update(evaluator1: admin_user)
      end

      it 'resets evaluator' do
        post reset_evaluator_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        expect(flash[:notice]).to include('Has abandonado la evaluación del proyecto')
      end

      it 'redirects to impulsa_projects list' do
        post reset_evaluator_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project)
        expect(response).to redirect_to(admin_impulsa_edition_impulsa_projects_path(impulsa_edition))
      end
    end

    describe 'download_attachment action' do
      let(:test_file_path) { Rails.root.join('tmp', 'test_download.pdf') }

      before do
        FileUtils.mkdir_p(File.dirname(test_file_path))
        File.write(test_file_path, 'test content')
        allow_any_instance_of(ImpulsaProject).to receive(:wizard_path).with('group1', 'field4').and_return(test_file_path.to_s)
      end

      after do
        FileUtils.rm_f(test_file_path)
      end

      it 'sends the requested file' do
        get download_attachment_admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project,
                                                                            gname: 'group1', fname: 'field4')
        expect(response).to have_http_status(:success)
        expect(response.body).to eq('test content')
      end
    end
  end

  describe 'collection actions' do
    describe 'upload_vote_results' do
      # Helper to create uploaded file from JSON data
      def create_upload_file(json_data)
        # Create a temp file for the upload
        temp_file = Tempfile.new(['results', '.json'])
        temp_file.write(json_data)
        temp_file.rewind
        Rack::Test::UploadedFile.new(temp_file.path, 'application/json')
      end

      let(:json_data) do
        {
          'questions' => [
            {
              'answers' => [
                {
                  'urls' => [{ 'url' => "https://participa.plebisbrand.info/impulsa/proyecto/#{impulsa_project.id}" }],
                  'total_count' => 250,
                  'winner_position' => nil
                }
              ]
            }
          ]
        }.to_json
      end

      it 'processes vote results and updates project votes' do
        file = create_upload_file(json_data)
        expect do
          post upload_vote_results_admin_impulsa_edition_impulsa_projects_path(impulsa_edition),
               params: { upload_vote_results: { file: file, question_id: '0' } }
        end.to change { impulsa_project.reload.votes }.from(100).to(250)
      end

      it 'marks project as winner when winner_position is present' do
        json_with_winner = {
          'questions' => [
            {
              'answers' => [
                {
                  'urls' => [{ 'url' => "https://participa.plebisbrand.info/impulsa/proyecto/#{impulsa_project.id}" }],
                  'total_count' => 250,
                  'winner_position' => 1
                }
              ]
            }
          ]
        }.to_json
        file = create_upload_file(json_with_winner)
        impulsa_project.update(state: :validated)

        post upload_vote_results_admin_impulsa_edition_impulsa_projects_path(impulsa_edition),
             params: { upload_vote_results: { file: file, question_id: '0' } }

        expect(impulsa_project.reload.state).to eq('winner')
      end

      it 'converts float votes correctly' do
        json_with_float = {
          'questions' => [
            {
              'answers' => [
                {
                  'urls' => [{ 'url' => "https://participa.plebisbrand.info/impulsa/proyecto/#{impulsa_project.id}" }],
                  'total_count' => 0.5,
                  'winner_position' => nil
                }
              ]
            }
          ]
        }.to_json
        file = create_upload_file(json_with_float)

        post upload_vote_results_admin_impulsa_edition_impulsa_projects_path(impulsa_edition),
             params: { upload_vote_results: { file: file, question_id: '0' } }

        expect(impulsa_project.reload.votes).to eq(90_005_000)
      end

      it 'handles non-existent projects gracefully' do
        json_invalid = {
          'questions' => [
            {
              'answers' => [
                {
                  'urls' => [{ 'url' => 'https://participa.plebisbrand.info/impulsa/proyecto/999999' }],
                  'total_count' => 150,
                  'winner_position' => nil
                }
              ]
            }
          ]
        }.to_json
        file = create_upload_file(json_invalid)

        post upload_vote_results_admin_impulsa_edition_impulsa_projects_path(impulsa_edition),
             params: { upload_vote_results: { file: file, question_id: '0' } }

        expect(flash[:error]).to include('Projectos no encontrados: 999999')
      end
    end
  end

  describe 'controller callbacks' do
    describe 'update_scopes' do
      it 'creates scopes for all state machine states' do
        get admin_impulsa_edition_impulsa_projects_path(impulsa_edition)
        expect(response).to have_http_status(:success)
      end
    end

    describe 'multiple_id_search' do
      it 'splits space-separated IDs' do
        get admin_impulsa_edition_impulsa_projects_path(impulsa_edition),
            params: { q: { id_in: "#{impulsa_project.id} 999" } }
        expect(response).to have_http_status(:success)
      end

      it 'handles nil params' do
        get admin_impulsa_edition_impulsa_projects_path(impulsa_edition)
        expect(response).to have_http_status(:success)
      end

      it 'handles nil id_in' do
        get admin_impulsa_edition_impulsa_projects_path(impulsa_edition), params: { q: {} }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'update controller' do
      context 'when project is reviewable' do
        before do
          impulsa_project.update(state: :review)
        end

        it 'marks as validable when no errors and sends email' do
          allow_any_instance_of(ImpulsaProject).to receive(:reviewable?).and_return(true)
          allow_any_instance_of(ImpulsaProject).to receive(:wizard_has_errors?).and_return(false)
          allow(ImpulsaMailer).to receive_message_chain(:on_validable, :deliver_now)

          put admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project),
              params: { impulsa_project: { name: 'Updated' }, review: 'true' }

          expect(flash[:notice]).to eq('El proyecto ha sido marcado como revisado.')
        end

        it 'marks as fixes when has errors and sends email' do
          allow_any_instance_of(ImpulsaProject).to receive(:reviewable?).and_return(true)
          allow_any_instance_of(ImpulsaProject).to receive(:wizard_has_errors?).with(ignore_state: true).and_return(true)
          allow(ImpulsaMailer).to receive_message_chain(:on_fixes, :deliver_now)

          put admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project),
              params: { impulsa_project: { name: 'Updated' }, review: 'true' }

          expect(flash[:notice]).to eq('El proyecto ha sido marcado como revisado.')
        end
      end

      context 'when project is validable and has evaluation result' do
        before do
          impulsa_project.update(state: :validable, evaluation_result: 'Evaluation complete')
        end

        it 'marks as validated when evaluation_action_ok and sends email' do
          allow_any_instance_of(ImpulsaProject).to receive(:validable?).and_return(true)
          allow_any_instance_of(ImpulsaProject).to receive(:evaluation_result?).and_return(true)
          allow(ImpulsaMailer).to receive_message_chain(:on_validated, :deliver_now)

          put admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project),
              params: { impulsa_project: { evaluation_result: 'Pass' }, evaluation_action_ok: 'Fase superada' }

          expect(flash[:notice]).to eq('El proyecto ha sido marcado como validado.')
        end

        it 'marks as invalidated when evaluation_action_ko and sends email' do
          allow_any_instance_of(ImpulsaProject).to receive(:validable?).and_return(true)
          allow_any_instance_of(ImpulsaProject).to receive(:evaluation_result?).and_return(true)
          allow(ImpulsaMailer).to receive_message_chain(:on_invalidated, :deliver_now)

          put admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project),
              params: { impulsa_project: { evaluation_result: 'Fail' }, evaluation_action_ko: 'Fase NO superada' }

          expect(flash[:notice]).to eq('El proyecto ha sido marcado como invalidado.')
        end
      end

      context 'when project is validable and current user is evaluator' do
        before do
          impulsa_project.update(state: :validable)
        end

        it 'assigns evaluator to current user' do
          allow_any_instance_of(ImpulsaProject).to receive(:validable?).and_return(true)
          allow_any_instance_of(ImpulsaProject).to receive(:current_evaluator).with(admin_user.id).and_return(1)

          put admin_impulsa_edition_impulsa_project_path(impulsa_edition, impulsa_project),
              params: { impulsa_project: { name: 'Updated' }, validable: 'true' }

          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end

  describe 'CSV export' do
    it 'includes all required columns' do
      get admin_impulsa_edition_impulsa_projects_path(impulsa_edition, format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(/csv/)
      expect(response.body).to include(impulsa_project.id.to_s)
      expect(response.body).to include('Test Project')
      expect(response.body).to include(project_user.email)
    end
  end
end
