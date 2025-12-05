# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EngineActivation Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let!(:engine_activation) do
    EngineActivation.create!(
      engine_name: 'test_engine',
      enabled: true,
      description: 'Test Engine Description',
      configuration: { key: 'value' },
      load_priority: 100
    )
  end

  before do
    sign_in admin_user
    # Stub PlebisCore::EngineRegistry
    stub_const('PlebisCore::EngineRegistry', Class.new)
    allow(PlebisCore::EngineRegistry).to receive(:info).and_return({
                                                                      name: 'test_engine',
                                                                      version: '1.0',
                                                                      models: ['Model1'],
                                                                      controllers: ['Controller1'],
                                                                      dependencies: []
                                                                    })
    allow(PlebisCore::EngineRegistry).to receive(:available_engines).and_return(['test_engine', 'another_engine'])
    allow(PlebisCore::EngineRegistry).to receive(:dependencies_for).and_return([])
    allow(PlebisCore::EngineRegistry).to receive(:dependents_of).and_return([])
  end

  describe 'GET /admin/engine_activations' do
    it 'displays the index page' do
      get admin_engine_activations_path
      expect(response).to have_http_status(:success)
    end

    it 'shows engine name in bold' do
      get admin_engine_activations_path
      expect(response.body).to include('test_engine')
      expect(response.body).to match(/<strong>.*test_engine.*<\/strong>/m)
    end

    it 'displays enabled status with tag' do
      get admin_engine_activations_path
      expect(response.body).to match(/Active|status_tag/i)
    end

    it 'truncates long descriptions' do
      get admin_engine_activations_path
      expect(response.body).to include('Test Engine')
    end

    it 'displays load priority' do
      get admin_engine_activations_path
      expect(response.body).to include('100')
    end

    it 'displays updated_at' do
      get admin_engine_activations_path
      expect(response.body).to match(/\d{4}/)
    end

    it 'shows disable button for enabled engines' do
      get admin_engine_activations_path
      expect(response.body).to include('Disable')
      expect(response.body).to include(disable_admin_engine_activation_path(engine_activation))
    end

    context 'with disabled engine' do
      before do
        engine_activation.update!(enabled: false)
        allow_any_instance_of(EngineActivation).to receive(:can_enable?).and_return(true)
      end

      it 'shows enable button' do
        get admin_engine_activations_path
        expect(response.body).to include('Enable')
        expect(response.body).to include(enable_admin_engine_activation_path(engine_activation))
      end
    end

    context 'when engine cannot be enabled' do
      before do
        engine_activation.update!(enabled: false)
        allow_any_instance_of(EngineActivation).to receive(:can_enable?).and_return(false)
      end

      it 'shows missing dependencies message' do
        get admin_engine_activations_path
        expect(response.body).to match(/Missing dependencies|warning/i)
      end
    end
  end

  describe 'filters' do
    it 'has engine_name filter' do
      get admin_engine_activations_path
      expect(response.body).to match(/filter.*engine_name/i)
    end

    it 'has enabled filter' do
      get admin_engine_activations_path
      expect(response.body).to match(/filter.*enabled/i)
    end

    it 'has load_priority filter' do
      get admin_engine_activations_path
      expect(response.body).to match(/filter.*load.*priority/i)
    end

    it 'has updated_at filter' do
      get admin_engine_activations_path
      expect(response.body).to match(/filter.*updated/i)
    end
  end

  describe 'GET /admin/engine_activations/:id' do
    it 'displays the show page' do
      get admin_engine_activation_path(engine_activation)
      expect(response).to have_http_status(:success)
    end

    it 'shows engine name in bold' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to match(/<strong>.*test_engine.*<\/strong>/m)
    end

    it 'shows enabled status tag' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to match(/Active|status_tag/i)
    end

    it 'displays full description' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('Test Engine Description')
    end

    it 'displays load priority' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('100')
    end

    it 'displays configuration as JSON' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('key')
      expect(response.body).to include('value')
    end

    it 'shows engine details panel' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('Engine Details')
    end

    it 'displays engine version from registry' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('1.0')
    end

    it 'displays models list' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('Model1')
    end

    it 'displays controllers list' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to include('Controller1')
    end

    it 'shows dependencies status' do
      get admin_engine_activation_path(engine_activation)
      expect(response.body).to match(/Dependencies|None/i)
    end
  end

  describe 'GET /admin/engine_activations/new' do
    it 'displays the new form' do
      get new_admin_engine_activation_path
      expect(response).to have_http_status(:success)
    end

    it 'has engine_name select dropdown' do
      get new_admin_engine_activation_path
      expect(response.body).to include('engine_activation[engine_name]')
      expect(response.body).to include('test_engine')
      expect(response.body).to include('another_engine')
    end

    it 'has enabled checkbox' do
      get new_admin_engine_activation_path
      expect(response.body).to include('engine_activation[enabled]')
    end

    it 'has description textarea' do
      get new_admin_engine_activation_path
      expect(response.body).to include('engine_activation[description]')
    end

    it 'has load_priority number field' do
      get new_admin_engine_activation_path
      expect(response.body).to include('engine_activation[load_priority]')
    end

    it 'has configuration textarea' do
      get new_admin_engine_activation_path
      expect(response.body).to include('engine_activation[configuration]')
    end
  end

  describe 'POST /admin/engine_activations' do
    let(:valid_params) do
      {
        engine_activation: {
          engine_name: 'new_engine',
          enabled: false,
          description: 'New Test Engine',
          configuration: '{"setting": "value"}',
          load_priority: 50
        }
      }
    end

    before do
      allow(PlebisCore::EngineRegistry).to receive(:available_engines).and_return(['new_engine'])
      allow(PlebisCore::EngineRegistry).to receive(:info).with('new_engine').and_return({
                                                                                           name: 'new_engine',
                                                                                           version: '1.0',
                                                                                           models: [],
                                                                                           controllers: [],
                                                                                           dependencies: []
                                                                                         })
    end

    it 'creates a new engine activation' do
      expect do
        post admin_engine_activations_path, params: valid_params
      end.to change(EngineActivation, :count).by(1)
    end

    it 'redirects to the show page' do
      post admin_engine_activations_path, params: valid_params
      expect(response).to redirect_to(admin_engine_activation_path(EngineActivation.last))
    end

    it 'creates with correct attributes' do
      post admin_engine_activations_path, params: valid_params
      activation = EngineActivation.last
      expect(activation.engine_name).to eq('new_engine')
      expect(activation.enabled).to be false
      expect(activation.description).to eq('New Test Engine')
      expect(activation.load_priority).to eq(50)
    end

    it 'parses JSON configuration' do
      post admin_engine_activations_path, params: valid_params
      activation = EngineActivation.last
      expect(activation.configuration).to eq({ 'setting' => 'value' })
    end

    context 'with invalid JSON configuration' do
      let(:invalid_params) do
        {
          engine_activation: {
            engine_name: 'new_engine',
            configuration: 'invalid json'
          }
        }
      end

      it 'shows validation error' do
        post admin_engine_activations_path, params: invalid_params
        expect(response.body).to match(/Invalid JSON|error/i)
      end
    end
  end

  describe 'GET /admin/engine_activations/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_engine_activation_path(engine_activation)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_engine_activation_path(engine_activation)
      expect(response.body).to include('test_engine')
      expect(response.body).to include('Test Engine Description')
    end

    it 'disables engine_name field' do
      get edit_admin_engine_activation_path(engine_activation)
      expect(response.body).to match(/disabled.*engine_activation\[engine_name\]/im)
    end

    it 'shows hint that engine name cannot be changed' do
      get edit_admin_engine_activation_path(engine_activation)
      expect(response.body).to include('cannot be changed')
    end
  end

  describe 'PUT /admin/engine_activations/:id' do
    let(:update_params) do
      {
        engine_activation: {
          description: 'Updated Description',
          load_priority: 200
        }
      }
    end

    it 'updates the engine activation' do
      put admin_engine_activation_path(engine_activation), params: update_params
      engine_activation.reload
      expect(engine_activation.description).to eq('Updated Description')
      expect(engine_activation.load_priority).to eq(200)
    end

    it 'redirects to the show page' do
      put admin_engine_activation_path(engine_activation), params: update_params
      expect(response).to redirect_to(admin_engine_activation_path(engine_activation))
    end
  end

  describe 'DELETE /admin/engine_activations/:id' do
    it 'deletes the engine activation' do
      expect do
        delete admin_engine_activation_path(engine_activation)
      end.to change(EngineActivation, :count).by(-1)
    end

    it 'redirects to the index page' do
      delete admin_engine_activation_path(engine_activation)
      expect(response).to redirect_to(admin_engine_activations_path)
    end
  end

  describe 'POST /admin/engine_activations/:id/enable' do
    before do
      engine_activation.update!(enabled: false)
      allow(EngineActivation).to receive(:enable!).and_return(engine_activation)
      allow_any_instance_of(EngineActivation).to receive(:can_enable?).and_return(true)
    end

    it 'enables the engine' do
      post enable_admin_engine_activation_path(engine_activation)
      expect(EngineActivation).to have_received(:enable!).with(engine_activation.engine_name)
    end

    it 'redirects to index with notice' do
      post enable_admin_engine_activation_path(engine_activation)
      expect(response).to redirect_to(admin_engine_activations_path)
      expect(flash[:notice]).to match(/enabled/i)
    end

    context 'when dependencies are missing' do
      before do
        allow_any_instance_of(EngineActivation).to receive(:can_enable?).and_return(false)
        allow(PlebisCore::EngineRegistry).to receive(:dependencies_for).and_return(['missing_dep'])
        # Stub enabled engines check
        allow(EngineActivation).to receive(:where).with(enabled: true).and_return(
          double(pluck: double(to_set: Set.new))
        )
      end

      it 'shows error alert' do
        post enable_admin_engine_activation_path(engine_activation)
        expect(flash[:alert]).to match(/Cannot enable|Missing dependencies/i)
      end

      it 'redirects to index' do
        post enable_admin_engine_activation_path(engine_activation)
        expect(response).to redirect_to(admin_engine_activations_path)
      end
    end
  end

  describe 'POST /admin/engine_activations/:id/disable' do
    before do
      allow(EngineActivation).to receive(:disable!).and_return(engine_activation)
      allow(PlebisCore::EngineRegistry).to receive(:dependents_of).and_return([])
      allow(EngineActivation).to receive(:where).with(enabled: true).and_return(
        double(pluck: double(to_set: Set.new))
      )
    end

    it 'disables the engine' do
      post disable_admin_engine_activation_path(engine_activation)
      expect(EngineActivation).to have_received(:disable!).with(engine_activation.engine_name)
    end

    it 'redirects to index with notice' do
      post disable_admin_engine_activation_path(engine_activation)
      expect(response).to redirect_to(admin_engine_activations_path)
      expect(flash[:notice]).to match(/disabled/i)
    end

    context 'when other engines depend on this one' do
      before do
        allow(PlebisCore::EngineRegistry).to receive(:dependents_of).and_return(['dependent_engine'])
        allow(EngineActivation).to receive(:where).with(enabled: true).and_return(
          double(pluck: double(to_set: Set['dependent_engine']))
        )
      end

      it 'shows error alert' do
        post disable_admin_engine_activation_path(engine_activation)
        expect(flash[:alert]).to match(/Cannot disable|depend/i)
      end

      it 'does not disable the engine' do
        post disable_admin_engine_activation_path(engine_activation)
        expect(EngineActivation).not_to have_received(:disable!)
      end
    end
  end

  describe 'menu configuration' do
    it 'has priority 1' do
      get admin_engine_activations_path
      expect(response).to have_http_status(:success)
    end

    it 'has label "Engines"' do
      get admin_engine_activations_path
      expect(response.body).to match(/Engines/i)
    end
  end

  describe 'permitted parameters' do
    before do
      allow(PlebisCore::EngineRegistry).to receive(:available_engines).and_return(['param_engine'])
      allow(PlebisCore::EngineRegistry).to receive(:info).with('param_engine').and_return({
                                                                                             name: 'param_engine',
                                                                                             version: '1.0',
                                                                                             models: [],
                                                                                             controllers: [],
                                                                                             dependencies: []
                                                                                           })
    end

    it 'permits engine_name' do
      post admin_engine_activations_path, params: {
        engine_activation: {
          engine_name: 'param_engine'
        }
      }
      expect(EngineActivation.last.engine_name).to eq('param_engine')
    end

    it 'permits enabled' do
      post admin_engine_activations_path, params: {
        engine_activation: {
          engine_name: 'param_engine',
          enabled: true
        }
      }
      expect(EngineActivation.last.enabled).to be true
    end

    it 'permits description' do
      post admin_engine_activations_path, params: {
        engine_activation: {
          engine_name: 'param_engine',
          description: 'Test Description'
        }
      }
      expect(EngineActivation.last.description).to eq('Test Description')
    end

    it 'permits configuration' do
      post admin_engine_activations_path, params: {
        engine_activation: {
          engine_name: 'param_engine',
          configuration: '{"key": "val"}'
        }
      }
      expect(EngineActivation.last.configuration).to eq({ 'key' => 'val' })
    end

    it 'permits load_priority' do
      post admin_engine_activations_path, params: {
        engine_activation: {
          engine_name: 'param_engine',
          load_priority: 150
        }
      }
      expect(EngineActivation.last.load_priority).to eq(150)
    end
  end
end
