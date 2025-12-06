# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProjectEvaluation, type: :model do
  # Test with actual ImpulsaProject model that includes the concern
  let(:edition) { create(:impulsa_edition, :active) }

  let(:evaluation_config) do
    {
      criteria1: {
        title: 'Technical Criteria',
        groups: {
          technical: {
            fields: {
              quality: { type: 'number', optional: false },
              innovation: { type: 'number', optional: false },
              feasibility: { type: 'number', optional: true }
            }
          }
        }
      },
      criteria2: {
        title: 'Social Impact',
        groups: {
          impact: {
            fields: {
              reach: { type: 'number', optional: false },
              sustainability: { type: 'number', optional: true }
            }
          }
        }
      },
      total: {
        title: 'Total Score',
        groups: {
          totals: {
            fields: {
              total_score: { type: 'number', sum: 'criteria1', export: 'total' }
            }
          }
        }
      }
    }
  end

  let(:category) { create(:impulsa_edition_category, impulsa_edition: edition, evaluation: evaluation_config) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }
  let(:project) do
    create(:impulsa_project,
           impulsa_edition_category: category,
           evaluator1: user1,
           evaluator2: user2)
  end

  # ====================
  # CONSTANTS TESTS
  # ====================

  describe 'constants' do
    it 'defines EVALUATORS constant' do
      expect(ImpulsaProject::EVALUATORS).to eq(2)
    end
  end

  # ====================
  # EVALUATOR ACCESSOR TESTS
  # ====================

  describe 'EvaluatorAccessor' do
    describe '#[]' do
      it 'returns evaluator by index' do
        expect(project.evaluator[1]).to eq(user1)
        expect(project.evaluator[2]).to eq(user2)
      end

      it 'returns nil for invalid index' do
        expect(project.evaluator[0]).to be_nil
        expect(project.evaluator[3]).to be_nil
        expect(project.evaluator[-1]).to be_nil
      end

      it 'returns nil for non-integer index' do
        expect(project.evaluator['1']).to be_nil
        expect(project.evaluator[1.5]).to be_nil
      end
    end

    describe '#[]=' do
      it 'sets evaluator by index' do
        new_evaluator = create(:user)
        project.evaluator[1] = new_evaluator
        expect(project.evaluator1).to eq(new_evaluator)
      end

      it 'raises error when setting same user for different evaluator slots' do
        expect {
          project.evaluator[2] = user1 # user1 is already evaluator1
        }.to raise_error(/Can't set same user as different evaluators/)
      end

      it 'allows setting same user to same slot' do
        expect {
          project.evaluator[1] = user1
        }.not_to raise_error
      end

      it 'does not set for invalid index' do
        new_evaluator = create(:user)
        project.evaluator[0] = new_evaluator
        project.evaluator[3] = new_evaluator
        expect(project.evaluator1).to eq(user1)
        expect(project.evaluator2).to eq(user2)
      end
    end
  end

  # ====================
  # EVALUATOR MANAGEMENT TESTS
  # ====================

  describe '#evaluators' do
    it 'returns range of evaluator indices' do
      expect(project.evaluators).to eq(1..2)
    end
  end

  describe '#evaluator' do
    it 'returns EvaluatorAccessor instance' do
      expect(project.evaluator).to be_a(PlebisImpulsa::ImpulsaProjectEvaluation::EvaluatorAccessor)
    end

    it 'memoizes the accessor' do
      accessor1 = project.evaluator
      accessor2 = project.evaluator
      expect(accessor1.object_id).to eq(accessor2.object_id)
    end
  end

  describe '#current_evaluator' do
    it 'returns index when user is assigned evaluator' do
      expect(project.current_evaluator(user1.id)).to eq(1)
      expect(project.current_evaluator(user2.id)).to eq(2)
    end

    it 'returns first empty slot for unassigned user' do
      project.update_columns(evaluator1_id: nil, evaluator2_id: nil)
      expect(project.current_evaluator(user3.id)).to eq(1)
    end

    it 'returns nil when all slots filled with different users' do
      expect(project.current_evaluator(user3.id)).to be_nil
    end

    it 'returns slot with blank evaluator' do
      project.update_column(:evaluator2_id, nil)
      expect(project.current_evaluator(user3.id)).to eq(2)
    end
  end

  describe '#is_current_evaluator?' do
    it 'returns true when user is an evaluator' do
      expect(project.is_current_evaluator?(user1.id)).to be true
      expect(project.is_current_evaluator?(user2.id)).to be true
    end

    it 'returns false when user is not an evaluator' do
      expect(project.is_current_evaluator?(user3.id)).to be false
    end

    it 'checks against _was value' do
      project.evaluator1 = user3
      # Before save, _was still points to user1
      expect(project.is_current_evaluator?(user1.id)).to be true
    end
  end

  describe '#reset_evaluator' do
    it 'clears evaluator and their evaluation' do
      project.evaluator1_evaluation = { 'technical.quality' => '10' }
      project.reset_evaluator(user1.id)

      expect(project.evaluator[1]).to be_nil
      expect(project.evaluator1_evaluation).to be_empty
    end

    it 'does nothing if user is not current evaluator' do
      original_eval1 = project.evaluator1
      project.reset_evaluator(user3.id)
      expect(project.evaluator1).to eq(original_eval1)
    end

    it 'resets correct evaluator slot' do
      project.evaluator1_evaluation = { 'technical.quality' => '10' }
      project.evaluator2_evaluation = { 'technical.quality' => '8' }

      project.reset_evaluator(user1.id)

      expect(project.evaluator1_evaluation).to be_empty
      expect(project.evaluator2_evaluation).to eq({ 'technical.quality' => '8' })
    end
  end

  describe '#evaluation_values' do
    it 'returns evaluation hash for evaluator 1' do
      project.evaluator1_evaluation = { 'technical.quality' => '10' }
      expect(project.evaluation_values(1)).to eq({ 'technical.quality' => '10' })
    end

    it 'returns evaluation hash for evaluator 2' do
      project.evaluator2_evaluation = { 'technical.quality' => '8' }
      expect(project.evaluation_values(2)).to eq({ 'technical.quality' => '8' })
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe '#evaluation_field_error' do
    it 'returns nil for valid field' do
      project.evaluator1_evaluation = { 'technical.quality' => '10' }
      error = project.evaluation_field_error(1, :technical, :quality)
      expect(error).to be_nil
    end

    it 'returns error for required field when blank' do
      project.evaluator1_evaluation = {}
      error = project.evaluation_field_error(1, :technical, :quality)
      expect(error).to eq('es obligatorio')
    end

    it 'returns nil for optional field when blank' do
      project.evaluator1_evaluation = {}
      error = project.evaluation_field_error(1, :technical, :feasibility)
      expect(error).to be_nil
    end

    it 'validates character limit' do
      limited_eval = evaluation_config.deep_dup
      limited_eval[:criteria1][:groups][:technical][:fields][:quality][:limit] = 2
      limited_eval[:criteria1][:groups][:technical][:fields][:quality][:type] = 'text'
      category_limited = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: limited_eval)
      project_limited = create(:impulsa_project, impulsa_edition_category: category_limited, evaluator1: user1)

      project_limited.evaluator1_evaluation = { 'technical.quality' => 'abc' }
      error = project_limited.evaluation_field_error(1, :technical, :quality)
      expect(error).to eq('puede tener hasta 2 caracteres')
    end

    it 'raises error for non-existent group' do
      # When group doesn't exist, it will raise NoMethodError trying to access fields on nil
      expect {
        project.evaluation_field_error(1, :invalid, :field)
      }.to raise_error(NoMethodError)
    end

    it 'validates email format when type is email' do
      email_eval = evaluation_config.deep_dup
      email_eval[:criteria1][:groups][:technical][:fields][:email] = { type: 'email', optional: false }
      category_email = create(:impulsa_edition_category, impulsa_edition: edition, evaluation: email_eval)
      project_email = create(:impulsa_project, impulsa_edition_category: category_email, evaluator1: user1)

      project_email.evaluator1_evaluation = { 'technical.email' => 'invalid-email' }
      error = project_email.evaluation_field_error(1, :technical, :email)
      expect(error).to be_present
    end
  end

  describe '#evaluation_step_errors' do
    it 'returns empty array when step is valid' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9'
      }
      errors = project.evaluation_step_errors(1, :criteria1)
      expect(errors).to be_empty
    end

    it 'returns array of errors for invalid fields' do
      project.evaluator1_evaluation = {}
      errors = project.evaluation_step_errors(1, :criteria1)
      expect(errors).not_to be_empty
      expect(errors.first[0]).to match(/_evl1_/)
      expect(errors.first[1]).to be_present
    end

    it 'formats error keys correctly' do
      project.evaluator1_evaluation = {}
      errors = project.evaluation_step_errors(1, :criteria1)
      error_keys = errors.map(&:first)
      expect(error_keys).to include('_evl1_technical__quality')
      expect(error_keys).to include('_evl1_technical__innovation')
    end
  end

  describe '#evaluation_has_errors?' do
    it 'returns false when all evaluators have valid data' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9',
        'impact.reach' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '8',
        'impact.reach' => '7'
      }
      expect(project.evaluation_has_errors?).to be false
    end

    it 'returns true when any evaluator has errors' do
      project.evaluator1_evaluation = {}
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '8',
        'impact.reach' => '7'
      }
      expect(project.evaluation_has_errors?).to be true
    end
  end

  describe '#evaluation_count_errors' do
    it 'returns 0 when evaluator has no errors' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9',
        'impact.reach' => '8'
      }
      expect(project.evaluation_count_errors(1)).to eq(0)
    end

    it 'returns count of all errors for evaluator' do
      project.evaluator1_evaluation = {}
      count = project.evaluation_count_errors(1)
      expect(count).to be.positive?
    end
  end

  # ====================
  # VALUE ASSIGNMENT TESTS
  # ====================

  describe '#assign_evaluation_value' do
    it 'assigns value for valid field' do
      result = project.assign_evaluation_value(1, :technical, :quality, '10')
      expect(result).to eq(:ok)
      expect(project.evaluation_values(1)['technical.quality']).to eq('10')
    end

    it 'returns :wrong_field for nonexistent group' do
      # assign_evaluation_value looks for the step containing the field
      # If no step contains that group.field combo, it returns :wrong_field
      result = project.assign_evaluation_value(1, :nonexistent, :field, 'value')
      expect(result).to eq(:wrong_field)
    end

    it 'returns :wrong_field for sum field' do
      result = project.assign_evaluation_value(1, :totals, :total_score, '100')
      expect(result).to eq(:wrong_field)
    end

    it 'triggers formula update after assignment' do
      project.assign_evaluation_value(1, :technical, :quality, '10')
      project.assign_evaluation_value(1, :technical, :innovation, '8')
      # total_score should be updated via formula (sums using to_i)
      expect(project.evaluation_values(1)['totals.total_score']).to eq(18)
    end
  end

  # ====================
  # FORMULA TESTS
  # ====================

  describe '#evaluation_update_formulas' do
    it 'updates sum fields for all evaluators' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '7'
      }

      project.evaluation_update_formulas

      expect(project.evaluation_values(1)['totals.total_score']).to eq(18)
      expect(project.evaluation_values(2)['totals.total_score']).to eq(16)
    end

    it 'skips evaluators that are not assigned' do
      project.update_column(:evaluator2_id, nil)
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '8'
      }

      expect {
        project.evaluation_update_formulas
      }.not_to raise_error
    end

    it 'handles optional fields in sum' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '8',
        'technical.feasibility' => '5'
      }

      project.evaluation_update_formulas
      expect(project.evaluation_values(1)['totals.total_score']).to eq(23)
    end

    it 'treats blank values as 0 in sum' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10'
      }

      project.evaluation_update_formulas
      expect(project.evaluation_values(1)['totals.total_score']).to eq(10)
    end
  end

  describe 'formula update on assignment' do
    it 'updates only affected formulas' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '8'
      }
      project.evaluation_update_formulas

      # Change a value that affects the sum
      project.assign_evaluation_value(1, :technical, :quality, '5')
      expect(project.evaluation_values(1)['totals.total_score']).to eq(13)
    end

    it 'handles cascading formula updates' do
      # If we had formulas that depend on other formulas, they should update
      project.assign_evaluation_value(1, :technical, :quality, '10')
      project.assign_evaluation_value(1, :technical, :innovation, '10')
      expect(project.evaluation_values(1)['totals.total_score']).to eq(20)
    end
  end

  # ====================
  # EXPORT TESTS
  # ====================

  describe '#evaluation_export' do
    it 'exports fields marked for export' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '7'
      }

      project.evaluation_update_formulas
      export = project.evaluation_export

      expect(export).to be_a(Hash)
      expect(export['evaluation_1_total']).to eq(18)
      expect(export['evaluation_2_total']).to eq(16)
    end

    it 'does not export fields without export key' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10'
      }
      export = project.evaluation_export
      expect(export.keys).not_to include('evaluation_1_quality')
    end

    it 'skips blank values' do
      project.evaluator1_evaluation = {}
      export = project.evaluation_export
      expect(export['evaluation_1_total']).to be_nil
    end

    it 'updates formulas before exporting' do
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '8'
      }
      # Don't manually update formulas
      export = project.evaluation_export
      # Should still have correct sum because export updates formulas
      expect(export['evaluation_1_total']).to eq(18)
    end
  end

  # ====================
  # ADMIN PARAMS TESTS
  # ====================

  describe '#evaluation_admin_params' do
    it 'returns array of permitted params for all evaluators' do
      params = project.evaluation_admin_params
      expect(params).to be_an(Array)
      expect(params).to include('_evl1_technical__quality')
      expect(params).to include('_evl2_technical__quality')
    end

    it 'excludes sum fields' do
      params = project.evaluation_admin_params
      expect(params).not_to include('_evl1_totals__total_score')
      expect(params).not_to include('_evl2_totals__total_score')
    end

    it 'includes all non-sum fields from all steps' do
      params = project.evaluation_admin_params
      expect(params).to include('_evl1_technical__quality')
      expect(params).to include('_evl1_technical__innovation')
      expect(params).to include('_evl1_impact__reach')
    end
  end

  # ====================
  # PATH TESTS
  # ====================

  describe '#evaluation_path' do
    it 'returns path with evaluator prefix' do
      project.evaluator1_evaluation = { 'files.document' => 'test.pdf' }
      path = project.evaluation_path(1, :files, :document)
      expect(path).to include('1-test.pdf')
    end
  end

  # ====================
  # DYNAMIC METHOD TESTS
  # ====================

  describe '#evaluation_method_missing' do
    it 'creates getter for evaluation field' do
      project.evaluator1_evaluation = { 'technical.quality' => '10' }
      expect(project._evl1_technical__quality).to eq('10')
    end

    it 'creates setter for evaluation field' do
      project._evl1_technical__quality = '9'
      expect(project.evaluation_values(1)['technical.quality']).to eq('9')
    end

    it 'creates methods for evaluator 2' do
      project.evaluator2_evaluation = { 'technical.quality' => '8' }
      expect(project._evl2_technical__quality).to eq('8')
    end

    it 'returns :super for unmatched methods' do
      result = project.evaluation_method_missing(:unknown_method)
      expect(result).to eq(:super)
    end

    it 'defines method on first call and reuses it' do
      project.evaluator1_evaluation = { 'technical.quality' => '10' }

      # First call defines the method
      expect(project._evl1_technical__quality).to eq('10')

      # Second call uses defined method
      project.evaluator1_evaluation['technical.quality'] = '9'
      expect(project._evl1_technical__quality).to eq('9')
    end
  end

  # ====================
  # FINISH EVALUATION TESTS
  # ====================

  describe '#can_finish_evaluation?' do
    let(:admin_user) { create(:user, admin: true) }
    let(:regular_user) { create(:user, admin: false) }

    it 'returns true when validable, no errors, and user is admin' do
      allow(project).to receive(:validable?).and_return(true)
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9',
        'impact.reach' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '8',
        'impact.reach' => '7'
      }

      expect(project.can_finish_evaluation?(admin_user)).to be true
    end

    it 'returns false when user is not admin' do
      allow(project).to receive(:validable?).and_return(true)
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9',
        'impact.reach' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '8',
        'impact.reach' => '7'
      }

      expect(project.can_finish_evaluation?(regular_user)).to be false
    end

    it 'returns false when project is not validable' do
      allow(project).to receive(:validable?).and_return(false)
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9',
        'impact.reach' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '8',
        'impact.reach' => '7'
      }

      expect(project.can_finish_evaluation?(admin_user)).to be false
    end

    it 'returns false when evaluation has errors' do
      allow(project).to receive(:validable?).and_return(true)
      project.evaluator1_evaluation = {}
      project.evaluator2_evaluation = {}

      expect(project.can_finish_evaluation?(admin_user)).to be false
    end

    it 'updates formulas before checking' do
      allow(project).to receive(:validable?).and_return(true)
      project.evaluator1_evaluation = {
        'technical.quality' => '10',
        'technical.innovation' => '9',
        'impact.reach' => '8'
      }
      project.evaluator2_evaluation = {
        'technical.quality' => '9',
        'technical.innovation' => '8',
        'impact.reach' => '7'
      }

      # Should call evaluation_update_formulas
      expect(project).to receive(:evaluation_update_formulas).and_call_original
      project.can_finish_evaluation?(admin_user)
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration tests' do
    it 'completes full evaluation flow' do
      # Evaluator 1 fills evaluation
      project._evl1_technical__quality = '10'
      project._evl1_technical__innovation = '9'
      project._evl1_impact__reach = '8'

      # Evaluator 2 fills evaluation
      project._evl2_technical__quality = '9'
      project._evl2_technical__innovation = '8'
      project._evl2_impact__reach = '7'

      # Check no errors
      expect(project.evaluation_has_errors?).to be false

      # Update and check formulas
      project.evaluation_update_formulas
      expect(project._evl1_totals__total_score).to eq(19)
      expect(project._evl2_totals__total_score).to eq(17)

      # Export
      export = project.evaluation_export
      expect(export['evaluation_1_total']).to eq(19)
      expect(export['evaluation_2_total']).to eq(17)
    end

    it 'prevents duplicate evaluator assignment' do
      expect {
        project.evaluator[2] = user1
      }.to raise_error(/Can't set same user/)
    end

    it 'allows reassignment of same evaluator' do
      expect {
        project.evaluator[1] = user1
      }.not_to raise_error
    end

    it 'handles evaluator reset and reassignment' do
      project._evl1_technical__quality = '10'
      project.reset_evaluator(user1.id)

      expect(project.evaluator1).to be_nil
      expect(project.evaluator1_evaluation).to be_empty

      # Reassign new evaluator
      project.evaluator[1] = user3
      project._evl1_technical__quality = '8'
      expect(project.evaluation_values(1)['technical.quality']).to eq('8')
    end
  end
end
