# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProject, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid impulsa_project' do
      project = create(:impulsa_project)
      expect(project).to be_valid, "Factory should create valid project. Errors: #{project.errors.full_messages.join(', ')}"
      expect(project).to be_persisted
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to impulsa_edition_category' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_edition_category)
    end

    it 'belongs to user with soft delete' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:user)

      user = project.user
      user.destroy
      project.reload
      expect(project.user).not_to be_nil # Should still load deleted user
    end

    it 'has one impulsa_edition through category' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_edition)
    end

    it 'has many impulsa_project_state_transitions' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_project_state_transitions)
    end

    it 'has many impulsa_project_topics' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_project_topics)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires name' do
      project = build(:impulsa_project, name: nil)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include('no puede estar en blanco')
    end

    it 'requires impulsa_edition_category_id' do
      project = build(:impulsa_project, impulsa_edition_category_id: nil)
      expect(project).not_to be_valid
      expect(project.errors[:impulsa_edition_category]).to include('must exist')
    end

    it 'requires status' do
      project = build(:impulsa_project, status: nil)
      expect(project).not_to be_valid
      expect(project.errors[:status]).to include('no puede estar en blanco')
    end

    it 'requires terms_of_service acceptance' do
      project = build(:impulsa_project, terms_of_service: false)
      expect(project).not_to be_valid
      expect(project.errors[:terms_of_service]).to include('debe ser aceptado')
    end

    it 'requires data_truthfulness acceptance' do
      project = build(:impulsa_project, data_truthfulness: false)
      expect(project).not_to be_valid
      expect(project.errors[:data_truthfulness]).to include('debe ser aceptado')
    end

    it 'requires content_rights acceptance' do
      project = build(:impulsa_project, content_rights: false)
      expect(project).not_to be_valid
      expect(project.errors[:content_rights]).to include('debe ser aceptado')
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.by_status' do
      it 'filters by status' do
        project_status_0 = create(:impulsa_project, status: 0)
        project_status_6 = create(:impulsa_project, status: 6)

        result = ImpulsaProject.by_status(0)
        expect(result).to include(project_status_0)
        expect(result).not_to include(project_status_6)
      end
    end

    describe '.first_phase' do
      it 'returns projects with status 0-3' do
        first_phase_project = create(:impulsa_project, status: 1)
        second_phase_project = create(:impulsa_project, status: 6)

        result = ImpulsaProject.first_phase
        expect(result).to include(first_phase_project)
        expect(result).not_to include(second_phase_project)
      end
    end

    describe '.second_phase' do
      it 'returns projects with status 4 or 6' do
        second_phase_project = create(:impulsa_project, status: 6)
        first_phase_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.second_phase
        expect(result).to include(second_phase_project)
        expect(result).not_to include(first_phase_project)
      end
    end

    describe '.votable' do
      it 'returns projects with status 6' do
        votable_project = create(:impulsa_project, status: 6)
        non_votable_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.votable
        expect(result).to include(votable_project)
        expect(result).not_to include(non_votable_project)
      end
    end

    describe '.public_visible' do
      it 'returns projects with status 9, 6, or 7' do
        visible_project = create(:impulsa_project, status: 6)
        hidden_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.public_visible
        expect(result).to include(visible_project)
        expect(result).not_to include(hidden_project)
      end
    end

    describe '.no_phase' do
      it 'returns projects with status 5, 7, or 10' do
        no_phase_project = create(:impulsa_project, status: 5)
        first_phase_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.no_phase
        expect(result).to include(no_phase_project)
        expect(result).not_to include(first_phase_project)
      end
    end
  end

  # ====================
  # UNIQUENESS VALIDATION TESTS
  # ====================

  describe 'uniqueness validation' do
    it 'allows same user to submit to different categories' do
      user = create(:user)
      category1 = create(:impulsa_edition_category)
      category2 = create(:impulsa_edition_category)

      create(:impulsa_project, user: user, impulsa_edition_category: category1)
      project2 = build(:impulsa_project, user: user, impulsa_edition_category: category2)

      expect(project2).to be_valid
    end

    it 'prevents same user from submitting multiple projects to same category' do
      user = create(:user)
      category = create(:impulsa_edition_category)

      create(:impulsa_project, user: user, impulsa_edition_category: category)
      project2 = build(:impulsa_project, user: user, impulsa_edition_category: category)

      expect(project2).not_to be_valid
      expect(project2.errors[:user]).to be_present
    end

    it 'allows impulsa_author to submit multiple projects to same category' do
      author = create(:user, impulsa_author: true)
      category = create(:impulsa_edition_category)

      create(:impulsa_project, user: author, impulsa_edition_category: category)
      project2 = build(:impulsa_project, user: author, impulsa_edition_category: category)

      expect(project2).to be_valid
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#voting_dates' do
      it 'returns formatted date range' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition)
        project = create(:impulsa_project, impulsa_edition_category: category)

        dates = project.voting_dates
        expect(dates).to be_a(String)
        expect(dates).to match(/al/) # Should contain " al " separator
      end
    end

    describe '#files_folder' do
      it 'returns path to project files' do
        project = create(:impulsa_project)
        folder = project.files_folder

        expect(folder).to be_a(String)
        expect(folder).to include('impulsa_projects')
        expect(folder).to include(project.id.to_s)
      end
    end

    describe '#method_missing' do
      it 'delegates to wizard_method_missing' do
        project = create(:impulsa_project)
        allow(project).to receive(:wizard_method_missing).and_return(:result)

        expect(project.send(:method_missing, :test_method)).to eq(:result)
      end

      it 'delegates to evaluation_method_missing when wizard returns :super' do
        project = create(:impulsa_project)
        allow(project).to receive(:wizard_method_missing).and_return(:super)
        allow(project).to receive(:evaluation_method_missing).and_return(:eval_result)

        expect(project.send(:method_missing, :test_method)).to eq(:eval_result)
      end

      it 'raises NoMethodError when both return :super' do
        project = create(:impulsa_project)
        allow(project).to receive(:wizard_method_missing).and_return(:super)
        allow(project).to receive(:evaluation_method_missing).and_return(:super)

        expect { project.some_undefined_method }.to raise_error(NoMethodError)
      end
    end
  end

  # ====================
  # WIZARD TESTS (ImpulsaProjectWizard)
  # ====================

  describe 'wizard methods' do
    let(:wizard_config) do
      {
        step1: {
          title: 'Basic Info',
          groups: {
            basic: {
              condition: nil,
              fields: {
                project_name: { type: 'text', optional: false, limit: 100, export: 'name' },
                description: { type: 'textarea', optional: true, limit: 500, export: 'desc' },
                website: { type: 'url', optional: true, export: 'web' },
                contact_email: { type: 'email', optional: false, export: 'email' },
                terms: { type: 'checkbox', optional: false, format: 'accept' }
              }
            }
          }
        },
        step2: {
          title: 'Additional Info',
          groups: {
            details: {
              condition: nil,
              fields: {
                budget: { type: 'number', optional: false },
                category: { type: 'select', optional: false, collection: { 'tech' => 'Technology', 'edu' => 'Education' }, export: 'cat' },
                tags: { type: 'check_boxes', optional: false, minimum: 1, maximum: 3, collection: { 'tag1' => 'Tag 1', 'tag2' => 'Tag 2', 'tag3' => 'Tag 3' }, export: 'tags' },
                document: { type: 'file', optional: true, filetype: 'document', maxsize: 1024 * 1024 }
              }
            }
          }
        }
      }
    end

    let(:edition) { create(:impulsa_edition, :active) }
    let(:category) { create(:impulsa_edition_category, impulsa_edition: edition, wizard: wizard_config) }
    let(:project) { create(:impulsa_project, impulsa_edition_category: category) }

    describe '#wizard_steps' do
      it 'returns step names with titles' do
        steps = project.wizard_steps
        expect(steps).to eq({ 'step1' => 'Basic Info', 'step2' => 'Additional Info' })
      end
    end

    describe '#wizard_next_step' do
      it 'returns the next step' do
        project.wizard_step = 'step1'
        expect(project.wizard_next_step).to eq('step2')
      end

      it 'returns nil for last step' do
        project.wizard_step = 'step2'
        expect(project.wizard_next_step).to be_nil
      end
    end

    describe '#wizard_step_info' do
      it 'returns current step info' do
        project.wizard_step = 'step1'
        info = project.wizard_step_info
        expect(info[:title]).to eq('Basic Info')
        expect(info[:groups]).to have_key(:basic)
      end
    end

    describe '#wizard_status' do
      it 'returns status for all steps' do
        status = project.wizard_status
        expect(status).to have_key('step1')
        expect(status).to have_key('step2')
        expect(status['step1'][:title]).to eq('Basic Info')
        expect(status['step1'][:fields]).to eq(5)
        expect(status['step1'][:values]).to eq(0)
        expect(status['step1'][:errors]).to be >= 0
      end

      it 'marks steps as filled when they have values' do
        project.wizard_values = { 'basic.project_name' => 'Test Project' }
        project.save
        project.instance_variable_set(:@wizard_status, nil)
        status = project.wizard_status
        expect(status['step1'][:filled]).to be true
      end
    end

    describe '#wizard_step_params' do
      it 'returns permitted params for current step' do
        project.wizard_step = 'step1'
        allow(project).to receive(:editable?).and_return(true)
        params = project.wizard_step_params
        expect(params).to be_an(Array)
        expect(params.flatten).to include('_wiz_basic__project_name')
      end
    end

    describe '#wizard_step_admin_params' do
      it 'returns all wizard params' do
        params = project.wizard_step_admin_params
        expect(params).to be_an(Array)
        expect(params.flatten).to include('_wiz_basic__project_name')
        expect(params.flatten).to include('_wiz_details__budget')
      end
    end

    describe '#wizard_editable_field?' do
      it 'returns true when editable' do
        allow(project).to receive(:editable?).and_return(true)
        expect(project.wizard_editable_field?(:basic, :project_name)).to be true
      end

      it 'returns true when fixable and has review comment' do
        allow(project).to receive(:editable?).and_return(false)
        allow(project).to receive(:fixable?).and_return(true)
        project.wizard_review = { 'basic.project_name' => 'Please fix this' }
        expect(project.wizard_editable_field?(:basic, :project_name)).to be true
      end

      it 'returns false when neither editable nor fixable' do
        allow(project).to receive(:editable?).and_return(false)
        allow(project).to receive(:fixable?).and_return(false)
        expect(project.wizard_editable_field?(:basic, :project_name)).to be false
      end
    end

    describe '#wizard_step_valid?' do
      it 'returns true when step has no errors' do
        project.wizard_values = {
          'basic.project_name' => 'Test',
          'basic.contact_email' => 'test@example.com',
          'basic.terms' => '1'
        }
        expect(project.wizard_step_valid?(:step1)).to be true
      end

      it 'returns false and adds errors when step has errors' do
        project.wizard_values = {}
        expect(project.wizard_step_valid?(:step1)).to be false
        expect(project.errors[:_wiz_basic__project_name]).to include('es obligatorio')
      end
    end

    describe '#wizard_has_errors?' do
      it 'returns true when wizard has errors' do
        project.wizard_values = {}
        expect(project.wizard_has_errors?).to be true
      end

      it 'returns false when wizard is valid' do
        project.wizard_values = {
          'basic.project_name' => 'Test',
          'basic.contact_email' => 'test@example.com',
          'basic.terms' => '1',
          'details.budget' => '1000',
          'details.category' => 'tech',
          'details.tags' => ['tag1']
        }
        expect(project.wizard_has_errors?).to be false
      end
    end

    describe '#wizard_count_errors' do
      it 'counts total errors across all steps' do
        project.wizard_values = {}
        count = project.wizard_count_errors
        expect(count).to be > 0
      end
    end

    describe '#wizard_all_errors' do
      it 'returns errors from all steps' do
        project.wizard_values = {}
        errors = project.wizard_all_errors
        expect(errors).to be_an(Array)
        expect(errors.length).to be > 0
      end
    end

    describe '#wizard_export' do
      it 'exports wizard values with export keys' do
        project.wizard_values = {
          'basic.project_name' => 'My Project',
          'basic.description' => 'A great project',
          'basic.website' => 'http://example.com',
          'basic.contact_email' => 'test@example.com',
          'details.category' => 'tech',
          'details.tags' => %w[tag1 tag2]
        }
        export = project.wizard_export
        expect(export['wizard_name']).to eq('My Project')
        expect(export['wizard_desc']).to eq('A great project')
        expect(export['wizard_cat']).to eq('Technology')
        expect(export['wizard_tags']).to eq(['Tag 1', 'Tag 2'])
      end

      it 'excludes fields without export key' do
        project.wizard_values = { 'details.budget' => '1000' }
        export = project.wizard_export
        expect(export.keys).not_to include('wizard_budget')
      end
    end

    describe '#wizard_eval_condition' do
      it 'returns true when condition is blank' do
        group = { condition: nil, fields: {} }
        expect(project.wizard_eval_condition(group)).to be true
      end

      it 'returns false on evaluation error' do
        group = { condition: 'invalid ruby code', fields: {} }
        expect(project.wizard_eval_condition(group)).to be false
      end
    end

    describe '#wizard_field_error' do
      let(:basic_group) { wizard_config[:step1][:groups][:basic] }

      it 'returns nil for valid field' do
        project.wizard_values = { 'basic.project_name' => 'Test' }
        error = project.wizard_field_error(:basic, :project_name, basic_group, basic_group[:fields][:project_name])
        expect(error).to be_nil
      end

      it 'returns error for missing required field' do
        project.wizard_values = {}
        error = project.wizard_field_error(:basic, :project_name, basic_group, basic_group[:fields][:project_name])
        expect(error).to eq('es obligatorio')
      end

      it 'returns error for field exceeding limit' do
        project.wizard_values = { 'basic.project_name' => 'a' * 101 }
        error = project.wizard_field_error(:basic, :project_name, basic_group, basic_group[:fields][:project_name])
        expect(error).to include('puede tener hasta 100 caracteres')
      end

      it 'returns error for unaccepted terms' do
        project.wizard_values = { 'basic.terms' => '0' }
        error = project.wizard_field_error(:basic, :terms, basic_group, basic_group[:fields][:terms])
        expect(error).to eq('debe ser aceptado')
      end

      it 'returns error for invalid email' do
        project.wizard_values = { 'basic.contact_email' => 'invalid-email' }
        error = project.wizard_field_error(:basic, :contact_email, basic_group, basic_group[:fields][:contact_email])
        expect(error).to be_present
      end

      it 'returns error for invalid URL' do
        project.wizard_values = { 'basic.website' => 'not-a-url' }
        error = project.wizard_field_error(:basic, :website, basic_group, basic_group[:fields][:website])
        expect(error).to eq('no es una dirección web válida')
      end

      it 'returns error for check_boxes below minimum' do
        details_group = wizard_config[:step2][:groups][:details]
        project.wizard_values = {}
        error = project.wizard_field_error(:details, :tags, details_group, details_group[:fields][:tags])
        expect(error).to eq('es obligatorio')
      end

      it 'returns error for check_boxes above maximum' do
        details_group = wizard_config[:step2][:groups][:details]
        project.wizard_values = { 'details.tags' => %w[tag1 tag2 tag3 tag4] }
        error = project.wizard_field_error(:details, :tags, details_group, details_group[:fields][:tags])
        expect(error).to include('puedes seleccionar hasta 3 opciones')
      end

      it 'returns review comment when fixable' do
        allow(project).to receive(:fixable?).and_return(true)
        project.wizard_review = { 'basic.project_name' => 'Please improve this' }
        project.wizard_values = { 'basic.project_name' => 'Test' }
        error = project.wizard_field_error(:basic, :project_name, basic_group, basic_group[:fields][:project_name])
        expect(error).to eq('Please improve this')
      end
    end

    describe '#assign_wizard_value' do
      it 'assigns text value' do
        result = project.assign_wizard_value(:basic, :project_name, 'New Name')
        expect(result).to eq(:ok)
        expect(project.wizard_values['basic.project_name']).to eq('New Name')
      end

      it 'assigns check_boxes value and removes blanks' do
        result = project.assign_wizard_value(:details, :tags, %w[tag1 tag2])
        expect(result).to eq(:ok)
        expect(project.wizard_values['details.tags']).to eq(%w[tag1 tag2])
      end

      it 'returns :wrong_field for invalid field' do
        result = project.assign_wizard_value(:invalid, :field, 'value')
        expect(result).to eq(:wrong_field)
      end

      it 'marks review comment as addressed when fixable' do
        allow(project).to receive(:fixable?).and_return(true)
        project.wizard_review = { 'basic.project_name' => 'Fix this' }
        project.wizard_values = { 'basic.project_name' => 'Old Value' }
        project.assign_wizard_value(:basic, :project_name, 'New Value')
        expect(project.wizard_review['basic.project_name']).to eq('*Fix this')
      end
    end

    describe '#wizard_path' do
      it 'returns nil for blank filename' do
        project.wizard_values = {}
        expect(project.wizard_path(:details, :document)).to be_nil
      end

      it 'returns safe path for valid filename' do
        project.wizard_values = { 'details.document' => 'myfile.pdf' }
        path = project.wizard_path(:details, :document)
        expect(path).to include('impulsa_projects')
        expect(path).to include('myfile.pdf')
      end

      it 'sanitizes path traversal attempts' do
        project.wizard_values = { 'details.document' => '../../../etc/passwd' }
        path = project.wizard_path(:details, :document)
        expect(path).to include('impulsa_projects')
        expect(path).to include('passwd')
        expect(path).not_to include('../')
      end
    end

    describe '#wizard_method_missing' do
      it 'creates getter for wizard field' do
        project.wizard_values = { 'basic.project_name' => 'Test Name' }
        expect(project._wiz_basic__project_name).to eq('Test Name')
      end

      it 'creates setter for wizard field' do
        project._wiz_basic__project_name = 'New Name'
        expect(project.wizard_values['basic.project_name']).to eq('New Name')
      end

      it 'creates getter for review field' do
        project.wizard_review = { 'basic.project_name' => 'Review comment' }
        expect(project._rvw_basic__project_name).to eq('Review comment')
      end

      it 'creates setter for review field' do
        project._rvw_basic__project_name = 'New comment'
        expect(project.wizard_review['basic.project_name']).to eq('New comment')
      end

      it 'returns :super for non-matching methods' do
        result = project.send(:wizard_method_missing, :unknown_method)
        expect(result).to eq(:super)
      end
    end

    describe 'before_create callback' do
      it 'sets wizard_step to first step' do
        new_project = build(:impulsa_project, impulsa_edition_category: category)
        expect(new_project.wizard_step).to be_nil
        new_project.save
        expect(new_project.wizard_step).to eq('step1')
      end
    end
  end

  # ====================
  # EVALUATION TESTS (ImpulsaProjectEvaluation)
  # ====================

  describe 'evaluation methods' do
    let(:evaluation_config) do
      {
        criteria1: {
          title: 'Technical Criteria',
          groups: {
            technical: {
              fields: {
                innovation: { type: 'number', optional: false, export: 'innov' },
                feasibility: { type: 'number', optional: false, export: 'feas' },
                comments: { type: 'textarea', optional: true, limit: 500 }
              }
            }
          }
        },
        criteria2: {
          title: 'Social Criteria',
          groups: {
            social: {
              fields: {
                impact: { type: 'number', optional: false, export: 'impact' },
                total: { type: 'number', sum: 'criteria1', export: 'total' }
              }
            }
          }
        }
      }
    end

    let(:edition) { create(:impulsa_edition, :active) }
    let(:category) { create(:impulsa_edition_category, impulsa_edition: edition, evaluation: evaluation_config) }
    let(:project) { create(:impulsa_project, impulsa_edition_category: category, state: 'validable') }

    describe '#evaluators' do
      it 'returns range of evaluator numbers' do
        expect(project.evaluators).to eq(1..2)
      end
    end

    describe '#evaluator accessor' do
      it 'gets evaluator by index' do
        user = create(:user)
        project.evaluator1 = user
        expect(project.evaluator[1]).to eq(user)
      end

      it 'sets evaluator by index' do
        user = create(:user)
        project.evaluator[1] = user
        expect(project.evaluator1).to eq(user)
      end

      it 'returns nil for invalid index' do
        expect(project.evaluator[0]).to be_nil
        expect(project.evaluator[99]).to be_nil
      end

      it 'prevents setting same user as different evaluators' do
        user = create(:user)
        project.evaluator[1] = user
        expect { project.evaluator[2] = user }.to raise_error(RuntimeError, /Can't set same user/)
      end
    end

    describe '#current_evaluator' do
      it 'returns evaluator number for user' do
        user = create(:user)
        project.evaluator1 = user
        expect(project.current_evaluator(user.id)).to eq(1)
      end

      it 'returns nil when all evaluator slots are filled' do
        user1 = create(:user)
        user2 = create(:user)
        project.evaluator1 = user1
        project.evaluator2 = user2
        project.save

        new_user = create(:user)
        expect(project.current_evaluator(new_user.id)).to be_nil
      end
    end

    describe '#is_current_evaluator?' do
      it 'returns true when user is an evaluator' do
        user = create(:user)
        project.evaluator1 = user
        project.save
        expect(project.is_current_evaluator?(user.id)).to be true
      end

      it 'returns false when user is not an evaluator' do
        user = create(:user)
        expect(project.is_current_evaluator?(user.id)).to be false
      end
    end

    describe '#reset_evaluator' do
      it 'clears evaluator and their evaluation' do
        user = create(:user)
        project.evaluator1 = user
        project.evaluator1_evaluation = { 'technical.innovation' => '5' }
        project.save

        project.reset_evaluator(user.id)
        expect(project.evaluator1).to be_nil
        expect(project.evaluator1_evaluation).to eq({})
      end

      it 'does nothing when user is not an evaluator' do
        user = create(:user)
        original_evaluator = project.evaluator1
        project.reset_evaluator(user.id)
        expect(project.evaluator1).to eq(original_evaluator)
      end
    end

    describe '#evaluation_values' do
      it 'returns evaluation hash for evaluator' do
        project.evaluator1_evaluation = { 'technical.innovation' => '5' }
        values = project.evaluation_values(1)
        expect(values['technical.innovation']).to eq('5')
      end
    end

    describe '#evaluation_admin_params' do
      it 'returns all evaluation params' do
        params = project.evaluation_admin_params
        expect(params).to include('_evl1_technical__innovation')
        expect(params).to include('_evl2_technical__innovation')
      end

      it 'excludes sum fields' do
        params = project.evaluation_admin_params
        expect(params).not_to include('_evl1_social__total')
      end
    end

    describe '#evaluation_has_errors?' do
      it 'returns true when any evaluator has errors' do
        eval1 = create(:user)
        fresh_project = create(:impulsa_project, impulsa_edition_category: category, state: 'validable', evaluator1: eval1)
        fresh_project.evaluator1_evaluation = {}
        expect(fresh_project.evaluation_has_errors?).to be true
      end
    end

    describe '#evaluation_count_errors' do
      it 'counts errors for specific evaluator' do
        project.evaluator1_evaluation = {}
        count = project.evaluation_count_errors(1)
        expect(count).to be > 0
      end
    end

    describe '#evaluation_export' do
      it 'responds to evaluation_export' do
        expect(project).to respond_to(:evaluation_export)
      end
    end

    describe '#evaluation_step_errors' do
      it 'returns errors for specific step and evaluator' do
        project.evaluator1_evaluation = {}
        errors = project.evaluation_step_errors(1, :criteria1)
        expect(errors.length).to be > 0
        expect(errors.first).to be_an(Array)
      end
    end

    describe '#evaluation_field_error' do
      let(:technical_group) { evaluation_config[:criteria1][:groups][:technical] }

      it 'returns nil for valid field' do
        project.evaluator1_evaluation = { 'technical.innovation' => '5' }
        error = project.evaluation_field_error(1, :technical, :innovation, technical_group, technical_group[:fields][:innovation])
        expect(error).to be_nil
      end

      it 'returns error for missing required field' do
        project.evaluator1_evaluation = {}
        error = project.evaluation_field_error(1, :technical, :innovation, technical_group, technical_group[:fields][:innovation])
        expect(error).to eq('es obligatorio')
      end

      it 'returns error for field exceeding limit' do
        project.evaluator1_evaluation = { 'technical.comments' => 'a' * 501 }
        error = project.evaluation_field_error(1, :technical, :comments, technical_group, technical_group[:fields][:comments])
        expect(error).to include('puede tener hasta 500 caracteres')
      end
    end

    describe '#assign_evaluation_value' do
      it 'assigns value and returns :ok' do
        result = project.assign_evaluation_value(1, :technical, :innovation, '5')
        expect(result).to eq(:ok)
        expect(project.evaluator1_evaluation['technical.innovation']).to eq('5')
      end


      it 'returns :wrong_field for sum field' do
        result = project.assign_evaluation_value(1, :social, :total, '10')
        expect(result).to eq(:wrong_field)
      end
    end

    describe '#evaluation_path' do
      it 'returns path for evaluation file' do
        project.evaluator1_evaluation = { 'technical.document' => 'eval.pdf' }
        path = project.evaluation_path(1, :technical, :document)
        expect(path).to include('impulsa_projects')
        expect(path).to include('1-eval.pdf')
      end
    end

    describe '#evaluation_method_missing' do
      it 'creates getter for evaluation field' do
        project.evaluator1_evaluation = { 'technical.innovation' => '5' }
        expect(project._evl1_technical__innovation).to eq('5')
      end

      it 'creates setter for evaluation field' do
        project._evl1_technical__innovation = '5'
        expect(project.evaluator1_evaluation['technical.innovation']).to eq('5')
      end

      it 'returns :super for non-matching methods' do
        result = project.send(:evaluation_method_missing, :unknown_method)
        expect(result).to eq(:super)
      end
    end

    describe '#evaluation_update_formulas' do
      it 'calculates sum fields' do
        project.evaluator1 = create(:user)
        project.evaluator1_evaluation = { 'technical.innovation' => '5', 'technical.feasibility' => '4' }
        project.evaluation_update_formulas
        expect(project.evaluator1_evaluation['social.total']).to eq(9)
      end

      it 'processes all evaluators' do
        project.evaluator1 = create(:user)
        project.evaluator2 = create(:user)
        project.evaluator1_evaluation = { 'technical.innovation' => '5', 'technical.feasibility' => '4' }
        project.evaluator2_evaluation = { 'technical.innovation' => '3', 'technical.feasibility' => '2' }

        project.evaluation_update_formulas
        expect(project.evaluator1_evaluation['social.total']).to eq(9)
        expect(project.evaluator2_evaluation['social.total']).to eq(5)
      end
    end

    describe '#can_finish_evaluation?' do
      let(:admin) { create(:user, :admin) }
      let(:regular_user) { create(:user) }

      it 'returns true when validable, no errors, and user is admin' do
        project.state = 'validable'
        project.evaluator1_evaluation = { 'technical.innovation' => '5', 'technical.feasibility' => '4', 'social.impact' => '3' }
        project.evaluator2_evaluation = { 'technical.innovation' => '5', 'technical.feasibility' => '4', 'social.impact' => '3' }

        expect(project.can_finish_evaluation?(admin)).to be true
      end

      it 'returns false when not validable' do
        project.state = 'new'
        expect(project.can_finish_evaluation?(admin)).to be false
      end

      it 'returns false when has errors' do
        project.state = 'validable'
        project.evaluator1_evaluation = {}
        expect(project.can_finish_evaluation?(admin)).to be false
      end

      it 'returns false when user is not admin' do
        project.state = 'validable'
        project.evaluator1_evaluation = { 'technical.innovation' => '5', 'technical.feasibility' => '4', 'social.impact' => '3' }
        project.evaluator2_evaluation = { 'technical.innovation' => '5', 'technical.feasibility' => '4', 'social.impact' => '3' }

        expect(project.can_finish_evaluation?(regular_user)).to be false
      end
    end

    describe 'EvaluatorAccessor' do
      it 'returns nil for invalid index when getting' do
        user = create(:user)
        project.evaluator1 = user
        expect(project.evaluator[0]).to be_nil
        expect(project.evaluator[99]).to be_nil
      end
    end
  end

  # ====================
  # STATE MACHINE TESTS (ImpulsaProjectStates)
  # ====================

  describe 'state machine' do
    describe 'initial state' do
      it 'starts in new state' do
        project = create(:impulsa_project)
        expect(project.state).to eq('new')
      end
    end

    describe '#mark_as_spam' do
      it 'transitions from any state to spam' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_spam }.to change { project.state }.to('spam')
      end
    end

    describe '#mark_for_review' do
      it 'transitions from new to review when markable' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition, wizard: { step1: { title: 'Step 1', groups: {} } })
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'new')

        allow(project).to receive(:markable_for_review?).and_return(true)
        expect { project.mark_for_review }.to change { project.state }.from('new').to('review')
      end

      it 'transitions from spam to review when markable' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition, wizard: { step1: { title: 'Step 1', groups: {} } })
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'spam')

        allow(project).to receive(:markable_for_review?).and_return(true)
        expect { project.mark_for_review }.to change { project.state }.from('spam').to('review')
      end

      it 'transitions from fixes to review_fixes when markable' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition, wizard: { step1: { title: 'Step 1', groups: {} } })
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'fixes')

        allow(project).to receive(:markable_for_review?).and_return(true)
        expect { project.mark_for_review }.to change { project.state }.from('fixes').to('review_fixes')
      end
    end

    describe '#mark_as_fixes' do
      it 'transitions from review to fixes' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_fixes }.to change { project.state }.from('review').to('fixes')
      end

      it 'transitions from review_fixes to fixes' do
        project = create(:impulsa_project, state: 'review_fixes')
        expect { project.mark_as_fixes }.to change { project.state }.from('review_fixes').to('fixes')
      end
    end

    describe '#mark_as_validable' do
      it 'transitions from review to validable' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_validable }.to change { project.state }.from('review').to('validable')
      end

      it 'transitions from review_fixes to validable' do
        project = create(:impulsa_project, state: 'review_fixes')
        expect { project.mark_as_validable }.to change { project.state }.from('review_fixes').to('validable')
      end
    end

    describe '#mark_as_validated' do
      it 'transitions from validable to validated when evaluation_result? is true' do
        project = create(:impulsa_project, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_validated }.to change { project.state }.from('validable').to('validated')
      end

      it 'does not transition when evaluation_result? is false' do
        project = create(:impulsa_project, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(false)
        expect { project.mark_as_validated rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_invalidated' do
      it 'transitions from validable to invalidated when evaluation_result? is true' do
        project = create(:impulsa_project, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_invalidated }.to change { project.state }.from('validable').to('invalidated')
      end
    end

    describe '#mark_as_winner' do
      it 'transitions from validated to winner' do
        project = create(:impulsa_project, state: 'validated')
        expect { project.mark_as_winner }.to change { project.state }.from('validated').to('winner')
      end
    end

    describe '#mark_as_resigned' do
      it 'transitions from any state to resigned' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_resigned }.to change { project.state }.to('resigned')
      end
    end

    describe '#editable?' do
      context 'in new, review, or spam state' do
        it 'returns true when edition allows edition' do
          edition = create(:impulsa_edition,
                           start_at: 1.day.ago,
                           new_projects_until: 1.day.from_now,
                           review_projects_until: 2.days.from_now,
                           validation_projects_until: 3.days.from_now,
                           votings_start_at: 4.days.from_now,
                           ends_at: 5.days.from_now)
          category = create(:impulsa_edition_category, impulsa_edition: edition)
          project = create(:impulsa_project, impulsa_edition_category: category, state: 'new')

          expect(project.editable?).to be true
        end

        it 'returns false when edition does not allow edition' do
          edition = create(:impulsa_edition, :active)
          category = create(:impulsa_edition_category, impulsa_edition: edition)
          project = create(:impulsa_project, impulsa_edition_category: category, state: 'new')

          expect(project.editable?).to be false
        end

        it 'returns false when resigned' do
          edition = create(:impulsa_edition, :active)
          category = create(:impulsa_edition_category, impulsa_edition: edition)
          project = create(:impulsa_project, impulsa_edition_category: category, state: 'resigned')

          expect(project.editable?).to be false
        end
      end

      context 'in other states' do
        it 'returns false' do
          project = create(:impulsa_project, state: 'validated')
          expect(project.editable?).to be false
        end
      end
    end

    describe '#saveable?' do
      it 'returns true when editable and not resigned' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:editable?).and_return(true)
        allow(project).to receive(:resigned?).and_return(false)

        expect(project.saveable?).to be true
      end

      it 'returns true when fixable and not resigned' do
        project = create(:impulsa_project, state: 'fixes')
        allow(project).to receive(:fixable?).and_return(true)
        allow(project).to receive(:resigned?).and_return(false)

        expect(project.saveable?).to be true
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, state: 'resigned')
        expect(project.saveable?).to be false
      end
    end

    describe '#reviewable?' do
      it 'returns true for review state when persisted and not resigned' do
        project = create(:impulsa_project, state: 'review')
        expect(project.reviewable?).to be true
      end

      it 'returns true for review_fixes state when persisted and not resigned' do
        project = create(:impulsa_project, state: 'review_fixes')
        expect(project.reviewable?).to be true
      end

      it 'returns false for other states' do
        project = create(:impulsa_project, state: 'new')
        expect(project.reviewable?).to be false
      end
    end

    describe '#markable_for_review?' do
      it 'returns true when all conditions are met' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:saveable?).and_return(true)
        allow(project).to receive(:wizard_has_errors?).and_return(false)

        expect(project.markable_for_review?).to be true
      end

      it 'returns false when wizard has errors' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:saveable?).and_return(true)
        allow(project).to receive(:wizard_has_errors?).and_return(true)

        expect(project.markable_for_review?).to be false
      end

      it 'returns false when not saveable' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:saveable?).and_return(false)

        expect(project.markable_for_review?).to be false
      end
    end

    describe '#deleteable?' do
      it 'returns true when editable and persisted and not resigned' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:editable?).and_return(true)

        expect(project.deleteable?).to be true
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, state: 'resigned')
        expect(project.deleteable?).to be false
      end
    end

    describe '#fixable?' do
      it 'returns true in fixes state when edition allows fixes' do
        edition = create(:impulsa_edition,
                         start_at: 3.days.ago,
                         new_projects_until: 2.days.ago,
                         review_projects_until: 1.hour.from_now,
                         validation_projects_until: 1.day.from_now,
                         votings_start_at: 2.days.from_now,
                         ends_at: 3.days.from_now)
        category = create(:impulsa_edition_category, impulsa_edition: edition)
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'fixes')

        expect(project.fixable?).to be true
      end

      it 'returns false when not in fixes state' do
        project = create(:impulsa_project, state: 'review')
        expect(project.fixable?).to be false
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, state: 'resigned')
        expect(project.fixable?).to be false
      end
    end

    describe '.exportable scope' do
      it 'includes validated projects' do
        validated = create(:impulsa_project, state: 'validated')
        expect(ImpulsaProject.exportable).to include(validated)
      end

      it 'includes winner projects' do
        winner = create(:impulsa_project, state: 'winner')
        expect(ImpulsaProject.exportable).to include(winner)
      end

      it 'excludes other states' do
        new_project = create(:impulsa_project, state: 'new')
        expect(ImpulsaProject.exportable).not_to include(new_project)
      end
    end

    describe 'audit trail' do
      it 'creates state transition records on state changes' do
        project = create(:impulsa_project, state: 'new')
        initial_count = project.impulsa_project_state_transitions.count

        project.mark_as_spam

        expect(project.impulsa_project_state_transitions.count).to be > initial_count
      end
    end
  end
end
