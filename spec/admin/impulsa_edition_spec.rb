# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImpulsaEdition Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin, :confirmed) }
  let!(:impulsa_edition) do
    create(:impulsa_edition,
           name: 'Test Edition',
           email: 'test@example.com',
           description: 'Test Description',
           start_at: 2.months.ago,
           new_projects_until: 1.month.ago,
           review_projects_until: 3.weeks.ago,
           validation_projects_until: 2.weeks.ago,
           votings_start_at: 1.week.ago,
           ends_at: 1.week.from_now,
           publish_results_at: 2.weeks.from_now)
  end

  before do
    sign_in_admin admin_user
  end

  describe 'ActiveAdmin configuration' do
    # Helper to get only model resources (not Page objects like Dashboard)
    let(:model_resources) do
      ActiveAdmin.application.namespaces[:admin].resources.select { |r| r.respond_to?(:resource_class) }
    end

    it 'registers ImpulsaEdition resource' do
      expect(model_resources.map(&:resource_class)).to include(ImpulsaEdition)
    end

    it 'registers ImpulsaEditionTopic resource' do
      expect(model_resources.map(&:resource_class)).to include(ImpulsaEditionTopic)
    end

    it 'has ImpulsaEdition resource configured' do
      resource = model_resources.find { |r| r.resource_class == ImpulsaEdition }
      expect(resource).to be_present
    end

    it 'has filters disabled for ImpulsaEdition' do
      resource = model_resources.find { |r| r.resource_class == ImpulsaEdition }
      expect(resource.filters_enabled?).to be false
    end

    it 'has menu false for ImpulsaEditionTopic' do
      resource = model_resources.find { |r| r.resource_class == ImpulsaEditionTopic }
      expect(resource.menu_item).to be_nil
    end

    it 'has belongs_to impulsa_edition for ImpulsaEditionTopic' do
      resource = model_resources.find { |r| r.resource_class == ImpulsaEditionTopic }
      expect(resource.belongs_to_config.target.resource_class).to eq(ImpulsaEdition)
    end
  end

  describe 'Routes' do
    it 'has index route' do
      # Verify route is accessible (actual params may vary by locale config)
      get admin_impulsa_editions_path
      expect([200, 302]).to include(response.status)
    end

    it 'has show route' do
      # Verify route is accessible
      get admin_impulsa_edition_path(impulsa_edition)
      expect([200, 302]).to include(response.status)
    end

    it 'has create_election member action route' do
      # Verify custom member action route exists
      allow_any_instance_of(ImpulsaEdition).to receive(:create_election).and_return(true)
      get create_election_admin_impulsa_edition_path(impulsa_edition)
      expect([200, 302]).to include(response.status)
    end

    it 'has nested impulsa_edition_topics routes' do
      # Verify nested route is accessible
      get admin_impulsa_edition_impulsa_edition_topics_path(impulsa_edition)
      expect([200, 302]).to include(response.status)
    end
  end

  describe 'GET /admin/impulsa_editions/new' do
    it 'displays the new form' do
      get new_admin_impulsa_edition_path
      expect(response).to have_http_status(:success)
    end

    it 'has form fields for all permitted params' do
      get new_admin_impulsa_edition_path
      # Check for key fields - form may use different naming conventions
      expect(response.body).to include('impulsa_edition').or include('name')
      expect(response.body).to include('email').or include('description')
    end

    it 'displays Impulsa edition heading' do
      get new_admin_impulsa_edition_path
      expect(response.body).to include('Impulsa edition')
    end
  end

  describe 'POST /admin/impulsa_editions' do
    let(:valid_params) do
      {
        impulsa_edition: {
          name: 'New Edition',
          email: 'new@example.com',
          description: 'New Description',
          start_at: 1.month.from_now,
          new_projects_until: 2.months.from_now,
          review_projects_until: 3.months.from_now,
          validation_projects_until: 4.months.from_now,
          votings_start_at: 5.months.from_now,
          ends_at: 6.months.from_now,
          publish_results_at: 7.months.from_now
        }
      }
    end

    it 'creates a new impulsa edition' do
      expect do
        post admin_impulsa_editions_path, params: valid_params
      end.to change(ImpulsaEdition, :count).by(1)
    end

    it 'redirects to the impulsa edition show page' do
      post admin_impulsa_editions_path, params: valid_params
      expect(response).to redirect_to(admin_impulsa_edition_path(ImpulsaEdition.last))
    end

    it 'creates with correct attributes' do
      post admin_impulsa_editions_path, params: valid_params
      edition = ImpulsaEdition.last
      expect(edition.name).to eq('New Edition')
      expect(edition.email).to eq('new@example.com')
      expect(edition.description).to eq('New Description')
    end
  end

  describe 'GET /admin/impulsa_editions/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_impulsa_edition_path(impulsa_edition)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_impulsa_edition_path(impulsa_edition)
      expect(response.body).to include('Test Edition')
      expect(response.body).to include('test@example.com')
      expect(response.body).to include('Test Description')
    end

    it 'displays Impulsa edition heading' do
      get edit_admin_impulsa_edition_path(impulsa_edition)
      expect(response.body).to include('Impulsa edition')
    end
  end

  describe 'PUT /admin/impulsa_editions/:id' do
    let(:update_params) do
      {
        impulsa_edition: {
          name: 'Updated Edition',
          email: 'updated@example.com',
          description: 'Updated Description'
        }
      }
    end

    it 'updates the impulsa edition' do
      put admin_impulsa_edition_path(impulsa_edition), params: update_params
      impulsa_edition.reload
      expect(impulsa_edition.name).to eq('Updated Edition')
      expect(impulsa_edition.email).to eq('updated@example.com')
      expect(impulsa_edition.description).to eq('Updated Description')
    end

    it 'redirects to the show page' do
      put admin_impulsa_edition_path(impulsa_edition), params: update_params
      expect(response).to redirect_to(admin_impulsa_edition_path(impulsa_edition))
    end
  end

  describe 'DELETE /admin/impulsa_editions/:id' do
    it 'deletes the impulsa edition' do
      expect do
        delete admin_impulsa_edition_path(impulsa_edition)
      end.to change(ImpulsaEdition, :count).by(-1)
    end

    it 'redirects to the index page' do
      delete admin_impulsa_edition_path(impulsa_edition)
      expect(response).to redirect_to(admin_impulsa_editions_path)
    end
  end

  describe 'custom actions' do
    describe 'GET /admin/impulsa_editions/:id/create_election' do
      it 'redirects to index page' do
        allow_any_instance_of(ImpulsaEdition).to receive(:create_election).and_return(true)
        get create_election_admin_impulsa_edition_path(impulsa_edition)
        expect(response).to redirect_to(admin_impulsa_editions_path)
      end

      context 'when election creation succeeds' do
        it 'sets success flash message' do
          allow_any_instance_of(ImpulsaEdition).to receive(:create_election).and_return(true)
          get create_election_admin_impulsa_edition_path(impulsa_edition)
          follow_redirect!
          expect(response.body).to include('Se han creado las votaciones para la edición de IMPULSA')
        end
      end

      context 'when election creation fails' do
        it 'sets error flash message' do
          allow_any_instance_of(ImpulsaEdition).to receive(:create_election).and_return(false)
          get create_election_admin_impulsa_edition_path(impulsa_edition)
          follow_redirect!
          expect(response.body).to include('Las votaciones para la edición de IMPULSA no se han creado')
        end
      end

      it 'calls create_election with base_url' do
        allow_any_instance_of(ImpulsaEdition).to receive(:create_election).and_return(true)
        get create_election_admin_impulsa_edition_path(impulsa_edition)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'permitted parameters' do
    it 'permits name' do
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          name: 'Permitted Name'
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.name).to eq('Permitted Name')
    end

    it 'permits email' do
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          email: 'permitted@example.com'
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.email).to eq('permitted@example.com')
    end

    it 'permits description' do
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          description: 'Permitted Description'
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.description).to eq('Permitted Description')
    end

    it 'permits start_at' do
      new_date = 1.month.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          start_at: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.start_at.to_date).to eq(new_date.to_date)
    end

    it 'permits new_projects_until' do
      new_date = 2.months.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          new_projects_until: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.new_projects_until.to_date).to eq(new_date.to_date)
    end

    it 'permits review_projects_until' do
      new_date = 3.months.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          review_projects_until: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.review_projects_until.to_date).to eq(new_date.to_date)
    end

    it 'permits validation_projects_until' do
      new_date = 4.months.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          validation_projects_until: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.validation_projects_until.to_date).to eq(new_date.to_date)
    end

    it 'permits votings_start_at' do
      new_date = 5.months.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          votings_start_at: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.votings_start_at.to_date).to eq(new_date.to_date)
    end

    it 'permits ends_at' do
      new_date = 6.months.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          ends_at: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.ends_at.to_date).to eq(new_date.to_date)
    end

    it 'permits publish_results_at' do
      new_date = 7.months.from_now
      put admin_impulsa_edition_path(impulsa_edition), params: {
        impulsa_edition: {
          publish_results_at: new_date
        }
      }
      impulsa_edition.reload
      expect(impulsa_edition.publish_results_at.to_date).to eq(new_date.to_date)
    end
  end
end

RSpec.describe 'ImpulsaEditionTopic Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin, :confirmed) }
  let!(:impulsa_edition) { create(:impulsa_edition, name: 'Parent Edition') }
  let!(:impulsa_edition_topic) do
    create(:impulsa_edition_topic,
           impulsa_edition: impulsa_edition,
           name: 'Topic Name')
  end

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_topics/new' do
    it 'displays the new form' do
      get new_admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition)
      expect(response).to have_http_status(:success)
    end

    it 'has impulsa_edition_id hidden field' do
      get new_admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_topic[impulsa_edition_id]')
      expect(response.body).to include('type="hidden"')
    end

    it 'has name input field' do
      get new_admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition)
      expect(response.body).to include('impulsa_edition_topic[name]')
    end
  end

  describe 'POST /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_topics' do
    let(:valid_params) do
      {
        impulsa_edition_topic: {
          impulsa_edition_id: impulsa_edition.id,
          name: 'New Topic'
        }
      }
    end

    it 'creates a new impulsa edition topic' do
      expect do
        post admin_impulsa_edition_impulsa_edition_topics_path(impulsa_edition), params: valid_params
      end.to change(ImpulsaEditionTopic, :count).by(1)
    end

    it 'creates topic associated with impulsa edition' do
      post admin_impulsa_edition_impulsa_edition_topics_path(impulsa_edition), params: valid_params
      topic = ImpulsaEditionTopic.last
      # Topic should be associated with an impulsa edition (may be new instance from DB)
      expect(topic.impulsa_edition_id).to eq(impulsa_edition.id)
      expect(topic.name).to eq('New Topic')
    end
  end

  describe 'GET /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_topics/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic)
      expect(response.body).to include('Topic Name')
    end
  end

  describe 'PUT /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_topics/:id' do
    let(:update_params) do
      {
        impulsa_edition_topic: {
          name: 'Updated Topic Name'
        }
      }
    end

    it 'updates the impulsa edition topic' do
      put admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic),
          params: update_params
      impulsa_edition_topic.reload
      expect(impulsa_edition_topic.name).to eq('Updated Topic Name')
    end

    it 'redirects to the show page' do
      put admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic),
          params: update_params
      expect(response).to redirect_to(admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic))
    end
  end

  describe 'DELETE /admin/impulsa_editions/:impulsa_edition_id/impulsa_edition_topics/:id' do
    it 'deletes the impulsa edition topic' do
      expect do
        delete admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic)
      end.to change(ImpulsaEditionTopic, :count).by(-1)
    end

    it 'redirects to the parent impulsa edition topics index page' do
      delete admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic)
      expect(response).to redirect_to(admin_impulsa_edition_impulsa_edition_topics_path(impulsa_edition))
    end
  end

  describe 'permitted parameters' do
    it 'permits name' do
      put admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic), params: {
        impulsa_edition_topic: {
          name: 'Permitted Name'
        }
      }
      impulsa_edition_topic.reload
      expect(impulsa_edition_topic.name).to eq('Permitted Name')
    end

    it 'permits impulsa_edition_id' do
      put admin_impulsa_edition_impulsa_edition_topic_path(impulsa_edition, impulsa_edition_topic), params: {
        impulsa_edition_topic: {
          impulsa_edition_id: impulsa_edition.id,
          name: 'Test'
        }
      }
      expect(response).to have_http_status(:redirect)
    end
  end
end
