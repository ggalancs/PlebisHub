# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaProjectEvaluation, type: :model do
    let(:edition) { create(:impulsa_edition, :current) }

    let(:evaluation_config) do
      {
        step1: {
          title: 'Technical Evaluation',
          groups: {
            technical: {
              fields: {
                score: { type: 'number', optional: false, export: 'technical_score' },
                comment: { type: 'text', limit: 1000, optional: true },
                feasibility: { type: 'select', collection: { low: 'Low', med: 'Medium', high: 'High' }, optional: false, export: 'feasibility' },
                approved: { type: 'checkbox', format: 'accept', optional: true }
              }
            }
          }
        },
        step2: {
          title: 'Social Impact',
          groups: {
            social: {
              fields: {
                impact_score: { type: 'number', optional: false },
                notes: { type: 'text', optional: true }
              }
            }
          }
        },
        totals: {
          title: 'Totals',
          groups: {
            totals: {
              fields: {
                total_step1: { type: 'number', sum: 'step1', optional: false, export: 'total_technical' }
              }
            }
          }
        }
      }
    end

    let(:category) { create(:impulsa_edition_category, impulsa_edition: edition, evaluation: evaluation_config) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:project) do
      create(:impulsa_project,
             impulsa_edition_category: category,
             evaluator1: user1,
             evaluator2: user2,
             state: 'validable')
    end

    # ====================
    # CONSTANTS TESTS
    # ====================

    describe 'constants' do
      it 'defines EVALUATORS constant' do
        expect(PlebisImpulsa::ImpulsaProjectEvaluation::EVALUATORS).to eq(2)
      end
    end

    # ====================
    # EVALUATOR ACCESSOR TESTS
    # ====================

    describe 'EvaluatorAccessor' do
      let(:accessor) { PlebisImpulsa::ImpulsaProjectEvaluation::EvaluatorAccessor.new(project) }

      describe '#[]' do
        it 'returns evaluator for valid index' do
          expect(accessor[1]).to eq(user1)
          expect(accessor[2]).to eq(user2)
        end

        it 'returns nil for index 0' do
          expect(accessor[0]).to be_nil
        end

        it 'returns nil for negative index' do
          expect(accessor[-1]).to be_nil
        end

        it 'returns nil for index beyond EVALUATORS' do
          expect(accessor[3]).to be_nil
        end

        it 'returns nil for non-integer index' do
          expect(accessor['1']).to be_nil
        end
      end

      describe '#[]=' do
        let(:new_user) { create(:user) }

        it 'sets evaluator for valid index' do
          accessor[1] = new_user
          expect(accessor[1]).to eq(new_user)
        end

        it 'raises error when setting same user as different evaluators' do
          expect do
            accessor[2] = user1
          end.to raise_error("Can't set same user as different evaluators for project.")
        end

        it 'allows setting same evaluator twice' do
          expect do
            accessor[1] = user1
          end.not_to raise_error
        end

        it 'allows setting nil' do
          accessor[1] = nil
          expect(accessor[1]).to be_nil
        end

        it 'does not set for index 0' do
          accessor[0] = new_user
          expect(project.evaluator1).to eq(user1) # Unchanged
        end

        it 'does not set for index beyond EVALUATORS' do
          accessor[3] = new_user
          expect(project.evaluator1).to eq(user1) # Unchanged
        end
      end
    end

    # ====================
    # ASSOCIATIONS TESTS
    # ====================

    describe 'associations' do
      it 'belongs to evaluator1' do
        expect(project.evaluator1).to eq(user1)
      end

      it 'belongs to evaluator2' do
        expect(project.evaluator2).to eq(user2)
      end

      it 'has evaluator1_evaluation store' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        project.save!
        expect(project.reload.evaluator1_evaluation['technical.score']).to eq('10')
      end

      it 'has evaluator2_evaluation store' do
        project.evaluator2_evaluation = { 'technical.score' => '8' }
        project.save!
        expect(project.reload.evaluator2_evaluation['technical.score']).to eq('8')
      end
    end

    # ====================
    # EVALUATOR METHODS TESTS
    # ====================

    describe '#evaluators' do
      it 'returns range 1 to EVALUATORS' do
        expect(project.evaluators).to eq(1..2)
      end
    end

    describe '#evaluator' do
      it 'returns EvaluatorAccessor instance' do
        expect(project.evaluator).to be_a(PlebisImpulsa::ImpulsaProjectEvaluation::EvaluatorAccessor)
      end

      it 'caches the accessor' do
        first_call = project.evaluator
        second_call = project.evaluator
        expect(first_call.object_id).to eq(second_call.object_id)
      end

      it 'allows accessing evaluators via bracket notation' do
        expect(project.evaluator[1]).to eq(user1)
        expect(project.evaluator[2]).to eq(user2)
      end
    end

    describe '#current_evaluator' do
      it 'returns 1 for user1' do
        expect(project.current_evaluator(user1.id)).to eq(1)
      end

      it 'returns 2 for user2' do
        expect(project.current_evaluator(user2.id)).to eq(2)
      end

      it 'returns nil for non-evaluator' do
        other_user = create(:user)
        expect(project.current_evaluator(other_user.id)).to be_nil
      end

      it 'returns first empty slot when evaluator is nil' do
        project.update_column(:evaluator1_id, nil)
        new_user = create(:user)
        expect(project.current_evaluator(new_user.id)).to eq(1)
      end
    end

    describe '#is_current_evaluator?' do
      it 'returns true for evaluator1' do
        expect(project.is_current_evaluator?(user1.id)).to be true
      end

      it 'returns true for evaluator2' do
        expect(project.is_current_evaluator?(user2.id)).to be true
      end

      it 'returns false for non-evaluator' do
        other_user = create(:user)
        expect(project.is_current_evaluator?(other_user.id)).to be false
      end
    end

    describe '#reset_evaluator' do
      it 'clears evaluator and evaluation data' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }

        project.reset_evaluator(user1.id)

        expect(project.evaluator[1]).to be_nil
        expect(project.evaluator1_evaluation).to be_empty
      end

      it 'does nothing for non-evaluator' do
        other_user = create(:user)
        project.evaluator1_evaluation = { 'technical.score' => '10' }

        project.reset_evaluator(other_user.id)

        expect(project.evaluator[1]).to eq(user1)
        expect(project.evaluator1_evaluation['technical.score']).to eq('10')
      end
    end

    describe '#evaluation_values' do
      it 'returns evaluation hash for evaluator 1' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        expect(project.evaluation_values(1)['technical.score']).to eq('10')
      end

      it 'returns evaluation hash for evaluator 2' do
        project.evaluator2_evaluation = { 'technical.score' => '8' }
        expect(project.evaluation_values(2)['technical.score']).to eq('8')
      end
    end

    # ====================
    # PARAMS GENERATION TESTS
    # ====================

    describe '#evaluation_admin_params' do
      it 'returns array of permitted params for all evaluators' do
        params = project.evaluation_admin_params
        expect(params).to be_an(Array)
        expect(params).to include('_evl1_technical__score')
        expect(params).to include('_evl1_technical__comment')
        expect(params).to include('_evl2_technical__score')
        expect(params).to include('_evl2_technical__comment')
      end

      it 'excludes sum fields' do
        params = project.evaluation_admin_params
        expect(params).not_to include('_evl1_totals__total_step1')
        expect(params).not_to include('_evl2_totals__total_step1')
      end
    end

    # ====================
    # VALIDATION TESTS
    # ====================

    describe '#evaluation_field_error' do
      it 'returns nil for valid field' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        error = project.evaluation_field_error(1, :technical, :score)
        expect(error).to be_nil
      end

      it 'returns "no es un campo" for non-existent field' do
        error = project.evaluation_field_error(1, :technical, :nonexistent)
        expect(error).to eq('no es un campo')
      end

      it 'returns "es obligatorio" for required field when blank' do
        project.evaluator1_evaluation = {}
        error = project.evaluation_field_error(1, :technical, :score)
        expect(error).to eq('es obligatorio')
      end

      it 'returns nil for optional field when blank' do
        project.evaluator1_evaluation = {}
        error = project.evaluation_field_error(1, :technical, :comment)
        expect(error).to be_nil
      end

      it 'validates "accept" format' do
        project.evaluator1_evaluation = { 'technical.approved' => '0' }
        error = project.evaluation_field_error(1, :technical, :approved)
        expect(error).to eq('debe ser aceptado')
      end

      it 'validates character limit' do
        project.evaluator1_evaluation = { 'technical.comment' => 'a' * 1001 }
        error = project.evaluation_field_error(1, :technical, :comment)
        expect(error).to eq('puede tener hasta 1000 caracteres')
      end

      it 'validates email format' do
        config_with_email = evaluation_config.deep_dup
        config_with_email[:step1][:groups][:technical][:fields][:email] = { type: 'email', optional: false }
        category_email = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config_with_email)
        project_email = create(:impulsa_project, impulsa_edition_category: category_email, state: 'validable')

        project_email.evaluator1_evaluation = { 'technical.email' => 'invalid' }
        error = project_email.evaluation_field_error(1, :technical, :email)
        expect(error).to be_present
      end
    end

    describe '#evaluation_step_errors' do
      it 'returns empty array when step is valid' do
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high'
        }
        errors = project.evaluation_step_errors(1, :step1)
        expect(errors).to be_empty
      end

      it 'returns array of errors for invalid fields' do
        project.evaluator1_evaluation = {}
        errors = project.evaluation_step_errors(1, :step1)
        expect(errors).not_to be_empty
        expect(errors.first).to be_an(Array)
        expect(errors.first.size).to eq(2) # [field_name, error]
        expect(errors.first[1]).to be_present # Error message
      end
    end

    describe '#evaluation_has_errors?' do
      it 'returns false when no errors' do
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high',
          'social.impact_score' => '8'
        }
        project.evaluator2_evaluation = {
          'technical.score' => '9',
          'technical.feasibility' => 'med',
          'social.impact_score' => '7'
        }
        expect(project.evaluation_has_errors?).to be false
      end

      it 'returns true when errors exist for any evaluator' do
        project.evaluator1_evaluation = {}
        project.evaluator2_evaluation = {
          'technical.score' => '9',
          'technical.feasibility' => 'med',
          'social.impact_score' => '7'
        }
        expect(project.evaluation_has_errors?).to be true
      end
    end

    describe '#evaluation_count_errors' do
      it 'returns 0 when no errors' do
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high',
          'social.impact_score' => '8'
        }
        expect(project.evaluation_count_errors(1)).to eq(0)
      end

      it 'returns count of all errors across steps' do
        project.evaluator1_evaluation = {}
        count = project.evaluation_count_errors(1)
        expect(count).to be > 0
      end
    end

    # ====================
    # VALUE ASSIGNMENT TESTS
    # ====================

    describe '#assign_evaluation_value' do
      it 'assigns value for valid field' do
        result = project.assign_evaluation_value(1, :technical, :score, '10')
        expect(result).to eq(:ok)
        expect(project.evaluator1_evaluation['technical.score']).to eq('10')
      end

      it 'returns :wrong_field for invalid field' do
        result = project.assign_evaluation_value(1, :invalid, :field, 'value')
        expect(result).to eq(:wrong_field)
      end

      it 'returns :wrong_field for sum field' do
        result = project.assign_evaluation_value(1, :totals, :total_step1, '10')
        expect(result).to eq(:wrong_field)
      end

      it 'updates formulas after assignment' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        project.assign_evaluation_value(1, :social, :impact_score, '5')

        # Formula should be updated (though we need to check the actual implementation)
        expect(project.evaluator1_evaluation['social.impact_score']).to eq('5')
      end
    end

    # ====================
    # EXPORT TESTS
    # ====================

    describe '#evaluation_export' do
      it 'exports fields marked for export' do
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high'
        }
        export = project.evaluation_export
        expect(export).to be_a(Hash)
        expect(export['evaluation_1_technical_score']).to eq('10')
        expect(export['evaluation_1_feasibility']).to eq('High')
      end

      it 'does not export fields without export key' do
        project.evaluator1_evaluation = {
          'technical.comment' => 'Good project'
        }
        export = project.evaluation_export
        expect(export.keys).not_to include('evaluation_1_comment')
      end

      it 'exports select field with collection value' do
        project.evaluator1_evaluation = {
          'technical.feasibility' => 'med'
        }
        export = project.evaluation_export
        expect(export['evaluation_1_feasibility']).to eq('Medium')
      end

      it 'skips blank values' do
        project.evaluator1_evaluation = {
          'technical.score' => ''
        }
        export = project.evaluation_export
        expect(export['evaluation_1_technical_score']).to be_nil
      end

      it 'exports for all evaluators' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        project.evaluator2_evaluation = { 'technical.score' => '8' }
        export = project.evaluation_export
        expect(export['evaluation_1_technical_score']).to eq('10')
        expect(export['evaluation_2_technical_score']).to eq('8')
      end

      it 'updates formulas before export' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        export = project.evaluation_export
        # Should call evaluation_update_formulas
        expect(export).to be_a(Hash)
      end
    end

    # ====================
    # DYNAMIC METHOD TESTS
    # ====================

    describe '#evaluation_method_missing' do
      it 'creates getter for evaluation field' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        expect(project._evl1_technical__score).to eq('10')
      end

      it 'creates setter for evaluation field' do
        project._evl1_technical__score = '9'
        expect(project.evaluator1_evaluation['technical.score']).to eq('9')
      end

      it 'works for evaluator 2' do
        project._evl2_technical__score = '8'
        expect(project.evaluator2_evaluation['technical.score']).to eq('8')
      end

      it 'returns :super for unmatched methods' do
        result = project.evaluation_method_missing(:unknown_method)
        expect(result).to eq(:super)
      end

      it 'defines method on first call and reuses it' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }

        # First call defines the method
        expect(project._evl1_technical__score).to eq('10')

        # Verify method is defined
        expect(project.class.instance_methods).to include(:_evl1_technical__score)

        # Second call should use the defined method
        project.evaluator1_evaluation['technical.score'] = '9'
        expect(project._evl1_technical__score).to eq('9')
      end
    end

    # ====================
    # FORMULA TESTS
    # ====================

    describe '#evaluation_update_formulas' do
      it 'updates formulas for all evaluators' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        project.evaluator2_evaluation = { 'technical.score' => '8' }

        project.evaluation_update_formulas

        # Both evaluators should have formulas updated
        expect(project.evaluator1_evaluation).to be_a(Hash)
        expect(project.evaluator2_evaluation).to be_a(Hash)
      end

      it 'calculates sum fields correctly' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }

        project.evaluation_update_formulas

        # total_step1 should be sum of all number fields in step1
        expect(project.evaluator1_evaluation['totals.total_step1']).to eq(10)
      end

      it 'skips evaluators without assigned user' do
        project.update_column(:evaluator2_id, nil)
        project.evaluator1_evaluation = { 'technical.score' => '10' }

        expect do
          project.evaluation_update_formulas
        end.not_to raise_error
      end
    end

    describe '#can_finish_evaluation?' do
      let(:admin_user) { create(:user, admin: true) }
      let(:regular_user) { create(:user, admin: false) }

      it 'returns true when validable, no errors, and user is admin' do
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high',
          'social.impact_score' => '8'
        }
        project.evaluator2_evaluation = {
          'technical.score' => '9',
          'technical.feasibility' => 'med',
          'social.impact_score' => '7'
        }

        expect(project.can_finish_evaluation?(admin_user)).to be true
      end

      it 'returns false when user is not admin' do
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high',
          'social.impact_score' => '8'
        }
        project.evaluator2_evaluation = {
          'technical.score' => '9',
          'technical.feasibility' => 'med',
          'social.impact_score' => '7'
        }

        expect(project.can_finish_evaluation?(regular_user)).to be false
      end

      it 'returns false when evaluation has errors' do
        project.evaluator1_evaluation = {}
        project.evaluator2_evaluation = {}

        expect(project.can_finish_evaluation?(admin_user)).to be false
      end

      it 'returns false when not validable' do
        project.update_column(:state, 'new')
        project.evaluator1_evaluation = {
          'technical.score' => '10',
          'technical.feasibility' => 'high',
          'social.impact_score' => '8'
        }
        project.evaluator2_evaluation = {
          'technical.score' => '9',
          'technical.feasibility' => 'med',
          'social.impact_score' => '7'
        }

        expect(project.can_finish_evaluation?(admin_user)).to be false
      end

      it 'updates formulas before checking' do
        project.evaluator1_evaluation = { 'technical.score' => '10' }
        project.evaluator2_evaluation = { 'technical.score' => '8' }

        expect(project).to receive(:evaluation_update_formulas).and_call_original
        project.can_finish_evaluation?(admin_user)
      end
    end

    # ====================
    # INTEGRATION TESTS
    # ====================

    describe 'integration tests' do
      it 'completes full evaluation flow' do
        # Evaluator 1 fills form
        project._evl1_technical__score = '10'
        project._evl1_technical__feasibility = 'high'
        project._evl1_social__impact_score = '8'

        # Evaluator 2 fills form
        project._evl2_technical__score = '9'
        project._evl2_technical__feasibility = 'med'
        project._evl2_social__impact_score = '7'

        # Check no errors
        expect(project.evaluation_has_errors?).to be false

        # Export results
        export = project.evaluation_export
        expect(export['evaluation_1_technical_score']).to eq('10')
        expect(export['evaluation_2_technical_score']).to eq('9')
      end

      it 'prevents duplicate evaluator assignment' do
        expect do
          project.evaluator[2] = user1
        end.to raise_error("Can't set same user as different evaluators for project.")
      end

      it 'allows resetting evaluator' do
        project._evl1_technical__score = '10'

        project.reset_evaluator(user1.id)

        expect(project.evaluator[1]).to be_nil
        expect(project.evaluator1_evaluation).to be_empty
      end
    end

    # ====================
    # ADDITIONAL VALIDATION TESTS
    # ====================

    describe 'additional validation tests' do
      it 'validates DNI/NIE format' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:dni] = { type: 'text', format: 'dni', optional: false }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.dni' => '12345678Z' }
        error = proj.evaluation_field_error(1, :technical, :dni)
        expect(error).to be_present
      end

      it 'validates NIE format' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:nie] = { type: 'text', format: 'nie', optional: false }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.nie' => 'invalid' }
        error = proj.evaluation_field_error(1, :technical, :nie)
        expect(error).to be_present
      end

      it 'validates CIF format' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:cif] = { type: 'text', format: 'cif', optional: false }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.cif' => 'invalid' }
        error = proj.evaluation_field_error(1, :technical, :cif)
        expect(error).to be_present
      end

      it 'validates DNINIE format' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:dninie] = { type: 'text', format: 'dninie', optional: false }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.dninie' => 'invalid' }
        error = proj.evaluation_field_error(1, :technical, :dninie)
        expect(error).to eq('no es un DNI o NIE correcto')
      end

      it 'validates phone format' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:phone] = { type: 'text', format: 'phone', optional: false }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.phone' => '+34600123456' }
        error = proj.evaluation_field_error(1, :technical, :phone)
        expect(error).to be_nil
      end

      it 'validates URL format' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:website] = { type: 'url', optional: false }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.website' => 'invalid' }
        error = proj.evaluation_field_error(1, :technical, :website)
        expect(error).to eq('no es una dirección web válida')
      end

      it 'exports check_boxes fields correctly' do
        config = evaluation_config.deep_dup
        config[:step1][:groups][:technical][:fields][:options] = {
          type: 'check_boxes',
          collection: { opt1: 'Option 1', opt2: 'Option 2' },
          export: 'options',
          optional: true
        }
        cat = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: config)
        proj = create(:impulsa_project, impulsa_edition_category: cat, state: 'validable')

        proj.evaluator1_evaluation = { 'technical.options' => ['opt1', 'opt2', ''] }
        export = proj.evaluation_export
        expect(export['evaluation_1_options']).to eq(['Option 1', 'Option 2'])
      end
    end

    # ====================
    # EVALUATION PATH TEST
    # ====================

    describe '#evaluation_path' do
      it 'returns path for evaluation file' do
        project.evaluator1_evaluation = { 'technical.file' => 'document.pdf' }
        allow(project).to receive(:files_folder).and_return('/uploads/')
        path = project.evaluation_path(1, :technical, :file)
        expect(path).to eq('/uploads/1-document.pdf')
      end
    end
  end
end
