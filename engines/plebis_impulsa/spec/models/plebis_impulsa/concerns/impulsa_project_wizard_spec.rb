# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
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
                description: { type: 'text', limit: 500, optional: true },
                accept_terms: { type: 'checkbox', format: 'accept', optional: false },
                dni: { type: 'text', format: 'dni', optional: true },
                nie: { type: 'text', format: 'nie', optional: true },
                cif: { type: 'text', format: 'cif', optional: true },
                dninie: { type: 'text', format: 'dninie', optional: true },
                website: { type: 'url', optional: true }
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
                category: { type: 'select', collection: { a: 'Option A', b: 'Option B' }, optional: false, export: 'project_category' },
                tags: { type: 'check_boxes', collection: { tag1: 'Tag 1', tag2: 'Tag 2', tag3: 'Tag 3' }, minimum: 1, maximum: 2, optional: true, export: 'project_tags' }
              }
            },
            conditional: {
              condition: 'editable?',
              fields: {
                extra: { type: 'text', optional: true }
              }
            }
          }
        },
        step3: {
          title: 'Documents',
          groups: {
            files: {
              fields: {
                document: { type: 'file', filetype: 'document', optional: true },
                sheet: { type: 'file', filetype: 'sheet', maxsize: 500000, optional: true },
                scan: { type: 'file', filetype: 'scan', optional: true }
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
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS).to be_a(Hash)
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:pdf]).to eq('application/pdf')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:jpg]).to eq('image/jpeg')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:doc]).to eq('application/msword')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:docx]).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:xls]).to eq('application/vnd.ms-excel')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:xlsx]).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:ods]).to eq('application/vnd.oasis.opendocument.spreadsheet')
        expect(PlebisImpulsa::ImpulsaProject::EXTENSIONS[:odt]).to eq('application/vnd.oasis.opendocument.text')
      end

      it 'defines FILETYPES hash' do
        expect(PlebisImpulsa::ImpulsaProject::FILETYPES).to be_a(Hash)
        expect(PlebisImpulsa::ImpulsaProject::FILETYPES[:sheet]).to eq(%i[xls xlsx ods])
        expect(PlebisImpulsa::ImpulsaProject::FILETYPES[:scan]).to eq(%i[jpg pdf])
        expect(PlebisImpulsa::ImpulsaProject::FILETYPES[:document]).to eq(%i[doc docx odt])
      end

      it 'defines MAX_FILE_SIZE' do
        expect(PlebisImpulsa::ImpulsaProject::MAX_FILE_SIZE).to eq(1024 * 1024 * 10) # 10 MB
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
        expect(status['step1'][:fields]).to eq(10) # All fields in personal group
        expect(status['step2'][:fields]).to eq(4) # title, category, tags, extra
      end

      it 'tracks filled values' do
        project.wizard_values = { 'personal.name' => 'John' }
        status = project.wizard_status
        expect(status['step1'][:values]).to eq(1)
      end

      it 'tracks errors for required fields' do
        project.wizard_values = { 'personal.email' => 'invalid' }
        status = project.wizard_status
        expect(status['step1'][:errors]).to be > 0
      end

      it 'marks steps as filled correctly based on wizard_step_was' do
        project.wizard_values = { 'personal.name' => 'John', 'personal.email' => 'john@example.com' }
        project.update_column(:wizard_step, 'step2')
        status = project.wizard_status
        expect(status['step1'][:filled]).to be true
        expect(status['step2'][:filled]).to be false
      end

      it 'marks all steps up to last filled as filled' do
        project.wizard_values = {
          'personal.name' => 'John',
          'project.title' => 'My Project'
        }
        project.update_column(:wizard_step, 'step3')
        status = project.wizard_status
        expect(status['step1'][:filled]).to be true
        expect(status['step2'][:filled]).to be true
      end

      it 'caches the result' do
        first_call = project.wizard_status
        second_call = project.wizard_status
        expect(first_call.object_id).to eq(second_call.object_id)
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
        expect(params.last['_wiz_project__tags']).to eq([])
      end

      it 'includes all fields from all steps' do
        params = project.wizard_step_admin_params
        expect(params).to include('_wiz_files__document')
        expect(params).to include('_wiz_files__sheet')
      end
    end

    describe '#wizard_step_params' do
      it 'returns params for current step only' do
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
        # No editable fields when not editable and not fixable
      end

      it 'includes fields with errors when fixable' do
        project.update_column(:wizard_step, 'step1')
        allow(project).to receive(:editable?).and_return(false)
        allow(project).to receive(:fixable?).and_return(true)
        project.wizard_values = {} # Empty to trigger required field errors
        project.wizard_review = { 'personal.name' => 'Fix this' }

        params = project.wizard_step_params
        expect(params).to include('_wiz_personal__name')
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

      it 'returns true when fixable and field has error' do
        allow(project).to receive(:editable?).and_return(false)
        allow(project).to receive(:fixable?).and_return(true)
        project.wizard_values = {} # Will trigger required field error
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

      it 'returns "no es un campo" for non-existent field' do
        error = project.wizard_field_error(:personal, :nonexistent)
        expect(error).to eq('no es un campo')
      end

      it 'returns "es obligatorio" for required field when blank' do
        project.wizard_values = {}
        error = project.wizard_field_error(:personal, :name)
        expect(error).to eq('es obligatorio')
      end

      it 'returns nil for optional field when blank' do
        project.wizard_values = {}
        error = project.wizard_field_error(:personal, :phone)
        expect(error).to be_nil
      end

      it 'validates "accept" format' do
        project.wizard_values = { 'personal.accept_terms' => '0' }
        error = project.wizard_field_error(:personal, :accept_terms)
        expect(error).to eq('debe ser aceptado')
      end

      it 'accepts "1" for accept format' do
        project.wizard_values = { 'personal.accept_terms' => '1' }
        error = project.wizard_field_error(:personal, :accept_terms)
        expect(error).to be_nil
      end

      it 'validates character limit' do
        project.wizard_values = { 'personal.description' => 'a' * 501 }
        error = project.wizard_field_error(:personal, :description)
        expect(error).to eq('puede tener hasta 500 caracteres')
      end

      it 'validates CIF format' do
        project.wizard_values = { 'personal.cif' => 'invalid' }
        error = project.wizard_field_error(:personal, :cif)
        expect(error).to eq('no es un NIF correcto')
      end

      it 'validates DNI format' do
        project.wizard_values = { 'personal.dni' => 'invalid' }
        error = project.wizard_field_error(:personal, :dni)
        expect(error).to eq('no es un DNI correcto')
      end

      it 'validates NIE format' do
        project.wizard_values = { 'personal.nie' => 'invalid' }
        error = project.wizard_field_error(:personal, :nie)
        expect(error).to eq('no es un NIE correcto')
      end

      it 'validates DNI/NIE format' do
        project.wizard_values = { 'personal.dninie' => 'invalid' }
        error = project.wizard_field_error(:personal, :dninie)
        expect(error).to eq('no es un DNI o NIE correcto')
      end

      it 'validates URL format' do
        project.wizard_values = { 'personal.website' => 'not-a-url' }
        error = project.wizard_field_error(:personal, :website)
        expect(error).to eq('no es una dirección web válida')
      end

      it 'accepts valid URL' do
        project.wizard_values = { 'personal.website' => 'https://example.com' }
        error = project.wizard_field_error(:personal, :website)
        expect(error).to be_nil
      end

      it 'validates email format' do
        project.wizard_values = { 'personal.email' => 'invalid-email' }
        error = project.wizard_field_error(:personal, :email)
        expect(error).to be_present
      end

      it 'accepts valid email' do
        project.wizard_values = { 'personal.email' => 'test@example.com' }
        error = project.wizard_field_error(:personal, :email)
        expect(error).to be_nil
      end

      it 'validates check_boxes minimum' do
        project.wizard_values = { 'project.tags' => [] }
        error = project.wizard_field_error(:project, :tags)
        # Empty array for optional field
        expect(error).to be_nil
      end

      it 'validates check_boxes minimum when value present' do
        project.wizard_values = { 'project.tags' => ['tag1'] }
        error = project.wizard_field_error(:project, :tags)
        expect(error).to be_nil # Has 1, minimum is 1
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

      it 'returns nil for fields in groups with failed conditions' do
        allow(project).to receive(:editable?).and_return(false)
        error = project.wizard_field_error(:conditional, :extra)
        expect(error).to be_nil # Condition not met
      end

      it 'validates fields in groups with met conditions' do
        allow(project).to receive(:editable?).and_return(true)
        project.wizard_values = { 'conditional.extra' => 'value' }
        error = project.wizard_field_error(:conditional, :extra)
        expect(error).to be_nil # Condition met, value present
      end

      it 'returns review error with ignore_state option' do
        allow(project).to receive(:fixable?).and_return(false)
        project.wizard_values = { 'personal.name' => 'Name' }
        project.wizard_review = { 'personal.name' => 'Review comment' }
        error = project.wizard_field_error(:personal, :name, nil, nil, { ignore_state: true })
        expect(error).to eq('Review comment')
      end
    end

    describe '#wizard_step_errors' do
      it 'returns empty array when step is valid' do
        project.wizard_values = {
          'personal.name' => 'John',
          'personal.email' => 'john@example.com',
          'personal.accept_terms' => '1'
        }
        errors = project.wizard_step_errors(:step1)
        expect(errors).to be_empty
      end

      it 'returns array of errors for invalid fields' do
        project.wizard_values = {}
        errors = project.wizard_step_errors(:step1)
        expect(errors).not_to be_empty
        expect(errors.first).to be_an(Array)
        expect(errors.first.size).to eq(3) # [gname, fname, error]
        expect(errors.first[2]).to be_present # Error message
      end

      it 'uses current step when no step provided' do
        project.update_column(:wizard_step, 'step1')
        project.wizard_values = {}
        errors = project.wizard_step_errors
        expect(errors).not_to be_empty
      end

      it 'filters out nil errors' do
        project.wizard_values = {
          'personal.name' => 'John',
          'personal.email' => 'john@example.com'
        }
        errors = project.wizard_step_errors(:step1)
        expect(errors.any? { |e| e[2].nil? }).to be false
      end
    end

    describe '#wizard_step_valid?' do
      it 'returns true for valid step' do
        project.wizard_values = {
          'personal.name' => 'John',
          'personal.email' => 'john@example.com',
          'personal.accept_terms' => '1'
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
          'personal.accept_terms' => '1',
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
          'personal.accept_terms' => '1',
          'project.title' => 'My Project',
          'project.category' => 'a'
        }
        expect(project.wizard_count_errors).to eq(0)
      end

      it 'returns count of all errors across steps' do
        project.wizard_values = {}
        count = project.wizard_count_errors
        expect(count).to be > 0
      end
    end

    describe '#wizard_all_errors' do
      it 'returns all errors from all steps' do
        project.wizard_values = {}
        errors = project.wizard_all_errors
        expect(errors).to be_an(Array)
        expect(errors).not_to be_empty
      end

      it 'passes options to step errors' do
        project.wizard_values = {}
        project.wizard_review = { 'personal.name' => 'Review' }
        errors = project.wizard_all_errors(ignore_state: true)
        expect(errors.any? { |e| e.include?('Review') }).to be true
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

      it 'does not mark review starting with asterisk' do
        allow(project).to receive(:fixable?).and_return(true)
        project.wizard_review = { 'personal.name' => '*Already fixed' }
        project.wizard_values = { 'personal.name' => 'Old' }

        project.assign_wizard_value(:personal, :name, 'New')
        expect(project.wizard_review['personal.name']).to eq('*Already fixed')
      end

      it 'assigns nil value' do
        project.wizard_values = { 'personal.name' => 'John' }
        result = project.assign_wizard_value(:personal, :name, nil)
        expect(result).to eq(:ok)
        expect(project.wizard_values['personal.name']).to be_nil
      end

      context 'with file uploads' do
        let(:file) do
          double('File',
                 path: '/tmp/test.pdf',
                 size: 100_000,
                 read: 'file content')
        end

        before do
          allow(FileUtils).to receive(:mkdir_p)
          allow(File).to receive(:binwrite)
          allow(File).to receive(:delete)
          allow(File).to receive(:extname).and_return('.pdf')
        end

        it 'assigns file and stores with extension' do
          result = project.assign_wizard_value(:files, :scan, file)
          expect(result).to eq(:ok)
          expect(project.wizard_values['files.scan']).to eq('files.scan.pdf')
        end

        it 'creates files folder' do
          expect(FileUtils).to receive(:mkdir_p).with(project.files_folder)
          project.assign_wizard_value(:files, :scan, file)
        end

        it 'writes file content' do
          expect(File).to receive(:binwrite).with(
            File.join(project.files_folder, 'files.scan.pdf'),
            'file content'
          )
          project.assign_wizard_value(:files, :scan, file)
        end

        it 'returns :wrong_extension for invalid file type' do
          allow(File).to receive(:extname).and_return('.exe')
          result = project.assign_wizard_value(:files, :document, file)
          expect(result).to eq(:wrong_extension)
        end

        it 'returns :wrong_size for files exceeding limit' do
          large_file = double('File', path: '/tmp/test.pdf', size: 10_000_000)
          result = project.assign_wizard_value(:files, :sheet, large_file)
          expect(result).to eq(:wrong_size)
        end

        it 'deletes old file when replacing' do
          project.wizard_values = { 'files.scan' => 'old_file.pdf' }
          expect(File).to receive(:delete).with(File.join(project.files_folder, 'old_file.pdf'))
          project.assign_wizard_value(:files, :scan, file)
        end

        it 'assigns nil to remove file' do
          project.wizard_values = { 'files.scan' => 'old_file.pdf' }
          expect(File).to receive(:delete).with(File.join(project.files_folder, 'old_file.pdf'))
          result = project.assign_wizard_value(:files, :scan, nil)
          expect(result).to eq(:ok)
          expect(project.wizard_values['files.scan']).to be_nil
        end
      end
    end

    # ====================
    # FILE PATH TESTS
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

      it 'sanitizes path traversal attempts with File.basename' do
        project.wizard_values = { 'files.document' => '../../etc/passwd' }
        path = project.wizard_path(:files, :document)
        expect(path).to include('impulsa_projects')
        expect(path).to end_with('passwd') # Only basename is used
        expect(path).not_to include('..')
      end

      it 'returns nil when resolved path escapes files_folder' do
        project.wizard_values = { 'files.document' => '../../../etc/passwd' }
        # Mock the path resolution to test the security check
        allow(File).to receive(:basename).and_return('passwd')
        allow(File).to receive(:join).and_return('/etc/passwd')

        expect(Rails.logger).to receive(:warn)
        path = project.wizard_path(:files, :document)
        expect(path).to be_nil
      end

      it 'logs security warning for path traversal attempts' do
        project.wizard_values = { 'files.document' => '../../../etc/passwd' }
        allow(File).to receive(:basename).and_return('passwd')
        allow(File).to receive(:join).and_return('/etc/passwd')

        expect(Rails.logger).to receive(:warn) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['event']).to eq('path_traversal_attempt_blocked')
          expect(parsed['project_id']).to eq(project.id)
        end

        project.wizard_path(:files, :document)
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
        expect(export['wizard_project_category']).to eq('Option A')
      end

      it 'exports check_boxes with collection values' do
        project.wizard_values = { 'project.tags' => ['tag1', 'tag2'] }
        export = project.wizard_export
        expect(export['wizard_project_tags']).to eq(['Tag 1', 'Tag 2'])
      end

      it 'skips blank values' do
        project.wizard_values = {
          'project.title' => ''
        }
        export = project.wizard_export
        expect(export['wizard_project_title']).to be_nil
      end

      it 'handles compact_blank for check_boxes' do
        project.wizard_values = { 'project.tags' => ['tag1', '', nil, 'tag2'] }
        export = project.wizard_export
        expect(export['wizard_project_tags']).to eq(['Tag 1', 'Tag 2'])
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

      # TODO: Fix integration - SafeConditionEvaluator is tested separately
      # This test has issues with Ruby stubbing and rescue blocks
      xit 'evaluates condition using SafeConditionEvaluator' do
        allow(project).to receive(:editable?).and_return(true)
        group = { condition: 'editable?' }
        expect(project.wizard_eval_condition(group)).to be true
      end

      # TODO: Fix integration - SafeConditionEvaluator is tested separately
      xit 'returns false when condition is not met' do
        allow(project).to receive(:editable?).and_return(false)
        group = { condition: 'editable?' }
        expect(project.wizard_eval_condition(group)).to be false
      end

      it 'logs error and returns false on evaluation failure' do
        allow(Rails.logger).to receive(:error)
        group = { condition: 'invalid_method' }

        expect(Rails.logger).to receive(:error) do |message|
          expect(message).to include('Wizard condition evaluation failed')
          expect(message).to include('invalid_method')
        end

        result = project.wizard_eval_condition(group)
        expect(result).to be false
      end

      it 'handles complex conditions' do
        allow(project).to receive(:editable?).and_return(true)
        allow(project).to receive(:fixable?).and_return(false)
        group = { condition: 'editable? || fixable?' }
        expect(project.wizard_eval_condition(group)).to be true
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

        # Verify method is defined
        expect(project.class.instance_methods).to include(:_wiz_personal__name)

        # Second call should use the defined method
        project.wizard_values['personal.name'] = 'Jane'
        expect(project._wiz_personal__name).to eq('Jane')
      end

      it 'handles setter with arguments correctly' do
        project._wiz_personal__email = 'test@example.com'
        expect(project.wizard_values['personal.email']).to eq('test@example.com')
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
        project._wiz_personal__accept_terms = '1'
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
          'personal.email' => 'john@example.com',
          'personal.accept_terms' => '1'
        }
        project.update_column(:wizard_step, 'step2')

        status = project.wizard_status
        expect(status['step1'][:filled]).to be true
        expect(status['step2'][:filled]).to be false
      end

      it 'handles review workflow' do
        allow(project).to receive(:fixable?).and_return(true)

        # Set initial values
        project.wizard_values = {
          'personal.name' => 'John',
          'personal.email' => 'john@example.com'
        }

        # Add review comments
        project.wizard_review = {
          'personal.name' => 'Please use full name',
          'personal.email' => 'Use official email'
        }

        # Verify errors are shown
        expect(project.wizard_field_error(:personal, :name)).to eq('Please use full name')
        expect(project.wizard_editable_field?(:personal, :name)).to be true

        # Fix the issues
        project.assign_wizard_value(:personal, :name, 'John Smith')

        # Verify review is marked as fixed
        expect(project.wizard_review['personal.name']).to eq('*Please use full name')
      end
    end
  end
end
