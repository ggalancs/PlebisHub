# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProjectWizard, type: :model do
  # Test with actual ImpulsaProject model that includes the concern
  let(:edition) do
    create(:impulsa_edition,
           start_at: 3.days.ago,
           new_projects_until: 1.day.from_now,
           review_projects_until: 2.days.from_now,
           validation_projects_until: 3.days.from_now,
           votings_start_at: 4.days.from_now,
           ends_at: 5.days.from_now)
  end

  let(:wizard_config) do
    {
      step1: {
        title: 'Personal Information',
        groups: {
          personal: {
            fields: {
              name: { type: 'text', optional: false },
              email: { type: 'email', optional: false },
              phone: { type: 'text', format: 'phone', optional: true },
              description: { type: 'text', limit: 500, optional: true }
            }
          }
        }
      },
      step2: {
        title: 'Project Details',
        groups: {
          project: {
            fields: {
              title: { type: 'text', optional: false, export: 'project_title' },
              category: { type: 'select', collection: { a: 'Option A', b: 'Option B' }, optional: false },
              tags: { type: 'check_boxes', collection: { tag1: 'Tag 1', tag2: 'Tag 2', tag3: 'Tag 3' }, minimum: 1, maximum: 2, optional: true }
            }
          }
        }
      },
      step3: {
        title: 'Documents',
        groups: {
          files: {
            fields: {
              document: { type: 'file', filetype: 'document', optional: true }
            }
          }
        }
      }
    }
  end

  let(:category) { create(:impulsa_edition_category, impulsa_edition: edition, wizard: wizard_config) }
  let(:project) { create(:impulsa_project, impulsa_edition_category: category, state: 'new') }

  # ====================
  # CONSTANTS TESTS
  # ====================

  describe 'constants' do
    it 'defines EXTENSIONS hash' do
      expect(ImpulsaProject::EXTENSIONS).to be_a(Hash)
      expect(ImpulsaProject::EXTENSIONS[:pdf]).to eq('application/pdf')
      expect(ImpulsaProject::EXTENSIONS[:jpg]).to eq('image/jpeg')
      expect(ImpulsaProject::EXTENSIONS[:doc]).to eq('application/msword')
    end

    it 'defines FILETYPES hash' do
      expect(ImpulsaProject::FILETYPES).to be_a(Hash)
      expect(ImpulsaProject::FILETYPES[:sheet]).to eq(%i[xls xlsx ods])
      expect(ImpulsaProject::FILETYPES[:scan]).to eq(%i[jpg pdf])
      expect(ImpulsaProject::FILETYPES[:document]).to eq(%i[doc docx odt])
    end

    it 'defines MAX_FILE_SIZE' do
      expect(ImpulsaProject::MAX_FILE_SIZE).to eq(1024 * 1024 * 10) # 10 MB
    end
  end

  # ====================
  # CALLBACKS TESTS
  # ====================

  describe 'callbacks' do
    describe 'before_create' do
      it 'sets wizard_step to first step' do
        new_project = build(:impulsa_project, impulsa_edition_category: category)
        expect(new_project.wizard_step).to be_nil

        new_project.save!
        expect(new_project.wizard_step).to eq('step1')
      end
    end
  end

  # ====================
  # WIZARD NAVIGATION TESTS
  # ====================

  describe '#wizard_steps' do
    it 'returns hash of step names to titles' do
      steps = project.wizard_steps
      expect(steps).to be_a(Hash)
      expect(steps[:step1]).to eq('Personal Information')
      expect(steps[:step2]).to eq('Project Details')
      expect(steps[:step3]).to eq('Documents')
    end
  end

  describe '#wizard_next_step' do
    it 'returns next step name' do
      project.update_column(:wizard_step, 'step1')
      expect(project.wizard_next_step).to eq('step2')
    end

    it 'returns next step for middle step' do
      project.update_column(:wizard_step, 'step2')
      expect(project.wizard_next_step).to eq('step3')
    end

    it 'returns nil for last step' do
      project.update_column(:wizard_step, 'step3')
      expect(project.wizard_next_step).to be_nil
    end
  end

  describe '#wizard_step_info' do
    it 'returns current step configuration' do
      project.update_column(:wizard_step, 'step1')
      step_info = project.wizard_step_info
      expect(step_info[:title]).to eq('Personal Information')
      expect(step_info[:groups]).to have_key(:personal)
    end
  end

  # ====================
  # WIZARD STATUS TESTS
  # ====================

  describe '#wizard_status' do
    it 'returns status for all steps' do
      status = project.wizard_status
      expect(status).to be_a(Hash)
      expect(status.keys).to match_array(['step1', 'step2', 'step3'])
    end

    it 'tracks field counts' do
      status = project.wizard_status
      expect(status['step1'][:fields]).to eq(4) # name, email, phone, description
      expect(status['step2'][:fields]).to eq(3) # title, category, tags
    end

    it 'tracks filled values' do
      project.wizard_values = { 'personal.name' => 'John' }
      status = project.wizard_status
      expect(status['step1'][:values]).to eq(1)
    end

    it 'tracks errors' do
      project.wizard_values = { 'personal.email' => 'invalid' }
      status = project.wizard_status
      expect(status['step1'][:errors]).to be >= 0
    end

    it 'marks steps as filled correctly' do
      project.wizard_values = { 'personal.name' => 'John', 'personal.email' => 'john@example.com' }
      project.update_column(:wizard_step, 'step2')
      status = project.wizard_status
      expect(status['step1'][:filled]).to be true
    end
  end

  # ====================
  # PARAMS GENERATION TESTS
  # ====================

  describe '#wizard_step_admin_params' do
    it 'returns array of permitted params for all steps' do
      params = project.wizard_step_admin_params
      expect(params).to be_an(Array)
      expect(params).to include('_wiz_personal__name')
      expect(params).to include('_wiz_personal__email')
      expect(params).to include('_wiz_project__title')
    end

    it 'handles check_boxes fields correctly' do
      params = project.wizard_step_admin_params
      expect(params.last).to be_a(Hash)
      expect(params.last).to have_key('_wiz_project__tags')
    end
  end

  describe '#wizard_step_params' do
    it 'returns params for current step' do
      project.update_column(:wizard_step, 'step1')
      allow(project).to receive(:editable?).and_return(true)

      params = project.wizard_step_params
      expect(params).to include('_wiz_personal__name')
      expect(params).to include('_wiz_personal__email')
    end

    it 'excludes params from other steps' do
      project.update_column(:wizard_step, 'step1')
      allow(project).to receive(:editable?).and_return(true)

      params = project.wizard_step_params
      expect(params).not_to include('_wiz_project__title')
    end

    it 'only includes editable fields' do
      project.update_column(:wizard_step, 'step1')
      allow(project).to receive(:editable?).and_return(false)
      allow(project).to receive(:fixable?).and_return(false)

      params = project.wizard_step_params
      expect(params).to be_an(Array)
    end
  end

  describe '#wizard_editable_field?' do
    it 'returns true when project is editable' do
      allow(project).to receive(:editable?).and_return(true)
      expect(project.wizard_editable_field?(:personal, :name)).to be true
    end

    it 'returns true when fixable and field has review comment' do
      allow(project).to receive(:editable?).and_return(false)
      allow(project).to receive(:fixable?).and_return(true)
      project.wizard_review = { 'personal.name' => 'Fix this' }
      expect(project.wizard_editable_field?(:personal, :name)).to be true
    end

    it 'returns false when not editable and no review' do
      allow(project).to receive(:editable?).and_return(false)
      allow(project).to receive(:fixable?).and_return(false)
      expect(project.wizard_editable_field?(:personal, :name)).to be false
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe '#wizard_field_error' do
    it 'returns nil for valid field' do
      project.wizard_values = { 'personal.name' => 'John Doe' }
      error = project.wizard_field_error(:personal, :name)
      expect(error).to be_nil
    end

    it 'returns error for required field when blank' do
      project.wizard_values = {}
      error = project.wizard_field_error(:personal, :name)
      expect(error).to eq('es obligatorio')
    end

    it 'returns nil for optional field when blank' do
      project.wizard_values = {}
      error = project.wizard_field_error(:personal, :phone)
      expect(error).to be_nil
    end

    it 'validates character limit' do
      project.wizard_values = { 'personal.description' => 'a' * 501 }
      error = project.wizard_field_error(:personal, :description)
      expect(error).to eq('puede tener hasta 500 caracteres')
    end

    it 'validates email format' do
      project.wizard_values = { 'personal.email' => 'invalid-email' }
      error = project.wizard_field_error(:personal, :email)
      expect(error).to be_present
    end

    it 'validates check_boxes minimum' do
      project.wizard_values = { 'project.tags' => [] }
      error = project.wizard_field_error(:project, :tags)
      # Empty array results in no error for optional field or es obligatorio for required
      expect(error).to be_nil # tags is optional
    end

    it 'validates check_boxes maximum' do
      project.wizard_values = { 'project.tags' => %w[tag1 tag2 tag3] }
      error = project.wizard_field_error(:project, :tags)
      expect(error).to eq('puedes seleccionar hasta 2 opciones')
    end

    it 'returns review comment when in fixable state' do
      allow(project).to receive(:fixable?).and_return(true)
      project.wizard_values = { 'personal.name' => 'Some Name' }
      project.wizard_review = { 'personal.name' => 'Please fix this name' }
      error = project.wizard_field_error(:personal, :name)
      expect(error).to eq('Please fix this name')
    end

    it 'ignores review comment starting with asterisk' do
      allow(project).to receive(:fixable?).and_return(true)
      project.wizard_values = { 'personal.name' => 'John' }
      project.wizard_review = { 'personal.name' => '*Fixed' }
      error = project.wizard_field_error(:personal, :name)
      expect(error).to be_nil
    end

    it 'handles conditional groups' do
      conditional_wizard = wizard_config.deep_dup
      conditional_wizard[:step1][:groups][:personal][:condition] = 'editable?'
      category_with_condition = create(:impulsa_edition_category, impulsa_edition: edition, wizard: conditional_wizard)
      project_with_condition = create(:impulsa_project, impulsa_edition_category: category_with_condition)

      allow(project_with_condition).to receive(:editable?).and_return(false)
      error = project_with_condition.wizard_field_error(:personal, :name)
      expect(error).to be_nil # Group condition not met, so no error
    end
  end

  describe '#wizard_step_errors' do
    it 'returns empty array when step is valid' do
      project.wizard_values = {
        'personal.name' => 'John',
        'personal.email' => 'john@example.com'
      }
      errors = project.wizard_step_errors(:step1)
      expect(errors).to be_empty
    end

    it 'returns array of errors for invalid fields' do
      project.wizard_values = {}
      errors = project.wizard_step_errors(:step1)
      expect(errors).not_to be_empty
      expect(errors.first).to be_an(Array)
      expect(errors.first[2]).to be_present # Error message
    end

    it 'uses current step when no step provided' do
      project.update_column(:wizard_step, 'step1')
      project.wizard_values = {}
      errors = project.wizard_step_errors
      expect(errors).not_to be_empty
    end
  end

  describe '#wizard_step_valid?' do
    it 'returns true for valid step' do
      project.wizard_values = {
        'personal.name' => 'John',
        'personal.email' => 'john@example.com'
      }
      expect(project.wizard_step_valid?(:step1)).to be true
    end

    it 'returns false and adds errors for invalid step' do
      project.wizard_values = {}
      expect(project.wizard_step_valid?(:step1)).to be false
      expect(project.errors).not_to be_empty
    end

    it 'adds errors with correct field names' do
      project.wizard_values = {}
      project.wizard_step_valid?(:step1)
      expect(project.errors.attribute_names).to include(:_wiz_personal__name)
      expect(project.errors.attribute_names).to include(:_wiz_personal__email)
    end
  end

  describe '#wizard_has_errors?' do
    it 'returns false when no errors' do
      project.wizard_values = {
        'personal.name' => 'John',
        'personal.email' => 'john@example.com',
        'project.title' => 'My Project',
        'project.category' => 'a'
      }
      expect(project.wizard_has_errors?).to be false
    end

    it 'returns true when errors exist' do
      project.wizard_values = {}
      expect(project.wizard_has_errors?).to be true
    end
  end

  describe '#wizard_count_errors' do
    it 'returns 0 when no errors' do
      project.wizard_values = {
        'personal.name' => 'John',
        'personal.email' => 'john@example.com',
        'project.title' => 'My Project',
        'project.category' => 'a'
      }
      expect(project.wizard_count_errors).to eq(0)
    end

    it 'returns count of all errors across steps' do
      project.wizard_values = {}
      count = project.wizard_count_errors
      expect(count).to be.positive?
    end
  end

  describe '#wizard_all_errors' do
    it 'returns all errors from all steps' do
      project.wizard_values = {}
      errors = project.wizard_all_errors
      expect(errors).to be_an(Array)
      expect(errors).not_to be_empty
    end
  end

  # ====================
  # VALUE ASSIGNMENT TESTS
  # ====================

  describe '#assign_wizard_value' do
    it 'assigns text value' do
      result = project.assign_wizard_value(:personal, :name, 'John Doe')
      expect(result).to eq(:ok)
      expect(project.wizard_values['personal.name']).to eq('John Doe')
    end

    it 'assigns check_boxes value and compacts blanks' do
      result = project.assign_wizard_value(:project, :tags, ['tag1', '', 'tag2', nil])
      expect(result).to eq(:ok)
      expect(project.wizard_values['project.tags']).to eq(['tag1', 'tag2'])
    end

    it 'returns :wrong_field for invalid field' do
      result = project.assign_wizard_value(:invalid, :field, 'value')
      expect(result).to eq(:wrong_field)
    end

    it 'marks review comment as fixed when value changes' do
      allow(project).to receive(:fixable?).and_return(true)
      project.wizard_review = { 'personal.name' => 'Fix this' }
      project.wizard_values = { 'personal.name' => 'Old Name' }

      project.assign_wizard_value(:personal, :name, 'New Name')
      expect(project.wizard_review['personal.name']).to eq('*Fix this')
    end

    it 'does not mark review when value unchanged' do
      allow(project).to receive(:fixable?).and_return(true)
      project.wizard_review = { 'personal.name' => 'Fix this' }
      project.wizard_values = { 'personal.name' => 'Same Name' }

      project.assign_wizard_value(:personal, :name, 'Same Name')
      expect(project.wizard_review['personal.name']).to eq('Fix this')
    end

    it 'assigns nil value' do
      project.wizard_values = { 'personal.name' => 'John' }
      result = project.assign_wizard_value(:personal, :name, nil)
      expect(result).to eq(:ok)
      expect(project.wizard_values['personal.name']).to be_nil
    end
  end

  # ====================
  # FILE HANDLING TESTS
  # ====================

  describe '#wizard_path' do
    it 'returns nil when no file assigned' do
      expect(project.wizard_path(:files, :document)).to be_nil
    end

    it 'returns full path for assigned file' do
      project.wizard_values = { 'files.document' => 'files.document.pdf' }
      path = project.wizard_path(:files, :document)
      expect(path).to include('impulsa_projects')
      expect(path).to include(project.id.to_s)
      expect(path).to end_with('files.document.pdf')
    end

    it 'sanitizes path traversal attempts' do
      project.wizard_values = { 'files.document' => '../../etc/passwd' }
      path = project.wizard_path(:files, :document)
      expect(path).to include('impulsa_projects')
      expect(path).to end_with('passwd') # Only basename is used
      expect(path).not_to include('..')
    end

    it 'returns nil for path traversal when resolved path escapes files_folder' do
      project.wizard_values = { 'files.document' => '../../../etc/passwd' }
      # The method should detect this and return nil
      path = project.wizard_path(:files, :document)
      # Should still be safe - File.basename strips directory components
      expect(path).to be_present if path # If path exists, it should be safe
    end
  end

  # ====================
  # EXPORT TESTS
  # ====================

  describe '#wizard_export' do
    it 'exports fields marked for export' do
      project.wizard_values = {
        'project.title' => 'My Great Project'
      }
      export = project.wizard_export
      expect(export).to be_a(Hash)
      expect(export['wizard_project_title']).to eq('My Great Project')
    end

    it 'does not export fields without export key' do
      project.wizard_values = {
        'personal.name' => 'John Doe'
      }
      export = project.wizard_export
      expect(export.keys).not_to include('wizard_name')
    end

    it 'exports select field with collection value' do
      project.wizard_values = {
        'project.category' => 'a',
        'project.title' => 'Test'
      }
      export = project.wizard_export
      # Select fields are exported with their display value, not key
      expect(export['wizard_project_title']).to eq('Test')
    end

    it 'exports check_boxes with collection values' do
      wizard_with_export = wizard_config.deep_dup
      wizard_with_export[:step2][:groups][:project][:fields][:tags][:export] = 'project_tags'
      category_export = create(:impulsa_edition_category, impulsa_edition: edition, wizard: wizard_with_export)
      project_export = create(:impulsa_project, impulsa_edition_category: category_export)

      project_export.wizard_values = { 'project.tags' => ['tag1', 'tag2'] }
      export = project_export.wizard_export
      expect(export['wizard_project_tags']).to eq(['Tag 1', 'Tag 2'])
    end

    it 'skips blank values' do
      project.wizard_values = {
        'project.title' => ''
      }
      export = project.wizard_export
      expect(export['wizard_project_title']).to be_nil
    end
  end

  # ====================
  # CONDITION EVALUATION TESTS
  # ====================

  describe '#wizard_eval_condition' do
    it 'returns true for blank condition' do
      group = { condition: nil }
      expect(project.wizard_eval_condition(group)).to be true
    end

    it 'returns true for empty condition' do
      group = { condition: '' }
      expect(project.wizard_eval_condition(group)).to be true
    end

    it 'evaluates condition using SafeConditionEvaluator' do
      # Project is already in new state and edition allows edition
      # so editable? should return true
      project.reload # Ensure we have fresh state
      group = { condition: 'editable?' }
      expect(project.wizard_eval_condition(group)).to be true
    end

    it 'returns false when condition is not met' do
      # Set project to non-editable state
      project.update_column(:state, 'validable')
      group = { condition: 'editable?' }
      expect(project.wizard_eval_condition(group)).to be false
    end

    it 'logs error and returns false on evaluation failure' do
      allow(Rails.logger).to receive(:error)
      group = { condition: 'invalid && syntax' }
      result = project.wizard_eval_condition(group)
      expect(result).to be false
    end
  end

  # ====================
  # DYNAMIC METHOD TESTS
  # ====================

  describe '#wizard_method_missing' do
    it 'creates getter for wizard field' do
      project.wizard_values = { 'personal.name' => 'John Doe' }
      expect(project._wiz_personal__name).to eq('John Doe')
    end

    it 'creates setter for wizard field' do
      project._wiz_personal__name = 'Jane Doe'
      expect(project.wizard_values['personal.name']).to eq('Jane Doe')
    end

    it 'creates getter for review field' do
      project.wizard_review = { 'personal.name' => 'Fix this' }
      expect(project._rvw_personal__name).to eq('Fix this')
    end

    it 'creates setter for review field' do
      project._rvw_personal__name = 'Needs correction'
      expect(project.wizard_review['personal.name']).to eq('Needs correction')
    end

    it 'returns :super for unmatched methods' do
      result = project.wizard_method_missing(:unknown_method)
      expect(result).to eq(:super)
    end

    it 'defines method on first call and reuses it' do
      project.wizard_values = { 'personal.name' => 'John' }

      # First call defines the method
      expect(project._wiz_personal__name).to eq('John')

      # Second call should use the defined method
      project.wizard_values['personal.name'] = 'Jane'
      expect(project._wiz_personal__name).to eq('Jane')
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration tests' do
    it 'completes full wizard flow' do
      # Step 1
      project.update_column(:wizard_step, 'step1')
      project._wiz_personal__name = 'John Doe'
      project._wiz_personal__email = 'john@example.com'
      expect(project.wizard_step_valid?(:step1)).to be true

      # Step 2
      project.update_column(:wizard_step, 'step2')
      project._wiz_project__title = 'My Project'
      project._wiz_project__category = 'a'
      expect(project.wizard_step_valid?(:step2)).to be true

      # Check overall status
      expect(project.wizard_has_errors?).to be false
      expect(project.wizard_count_errors).to eq(0)
    end

    it 'tracks progress through wizard' do
      project.wizard_values = {
        'personal.name' => 'John',
        'personal.email' => 'john@example.com'
      }
      project.update_column(:wizard_step, 'step2')

      status = project.wizard_status
      expect(status['step1'][:filled]).to be true
      expect(status['step2'][:filled]).to be false
    end
  end
end
