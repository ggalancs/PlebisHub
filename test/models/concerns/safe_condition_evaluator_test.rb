require "test_helper"

class SafeConditionEvaluatorTest < ActiveSupport::TestCase
  # Test with a simple mock object that includes the concern
  class TestModel
    include SafeConditionEvaluator

    attr_accessor :editable, :reviewable, :validable

    def editable?
      @editable || false
    end

    def reviewable?
      @reviewable || false
    end

    def validable?
      @validable || false
    end

    def persisted?
      true
    end
  end

  setup do
    @model = TestModel.new
  end

  # BASIC EVALUATION TESTS

  test "evaluate should return true for blank condition" do
    result = SafeConditionEvaluator.evaluate(@model, "")
    assert_equal true, result
  end

  test "evaluate should return true for nil condition" do
    result = SafeConditionEvaluator.evaluate(@model, nil)
    assert_equal true, result
  end

  test "evaluate should call whitelisted method and return boolean" do
    @model.editable = true
    result = SafeConditionEvaluator.evaluate(@model, "editable?")
    assert_equal true, result
  end

  test "evaluate should return false when method returns false" do
    @model.editable = false
    result = SafeConditionEvaluator.evaluate(@model, "editable?")
    assert_equal false, result
  end

  # BOOLEAN OPERATOR TESTS

  test "evaluate should handle AND operator correctly" do
    @model.editable = true
    @model.reviewable = true
    result = SafeConditionEvaluator.evaluate(@model, "editable? && reviewable?")
    assert_equal true, result
  end

  test "evaluate should return false for AND when one is false" do
    @model.editable = true
    @model.reviewable = false
    result = SafeConditionEvaluator.evaluate(@model, "editable? && reviewable?")
    assert_equal false, result
  end

  test "evaluate should handle OR operator correctly" do
    @model.editable = true
    @model.reviewable = false
    result = SafeConditionEvaluator.evaluate(@model, "editable? || reviewable?")
    assert_equal true, result
  end

  test "evaluate should return false for OR when both are false" do
    @model.editable = false
    @model.reviewable = false
    result = SafeConditionEvaluator.evaluate(@model, "editable? || reviewable?")
    assert_equal false, result
  end

  test "evaluate should handle NOT operator correctly" do
    @model.editable = false
    result = SafeConditionEvaluator.evaluate(@model, "!editable?")
    assert_equal true, result
  end

  test "evaluate should handle complex boolean expression" do
    @model.editable = true
    @model.reviewable = false
    @model.validable = true
    result = SafeConditionEvaluator.evaluate(@model, "editable? && !reviewable? && validable?")
    assert_equal true, result
  end

  test "evaluate should handle multiple OR conditions" do
    @model.editable = false
    @model.reviewable = false
    @model.validable = true
    result = SafeConditionEvaluator.evaluate(@model, "editable? || reviewable? || validable?")
    assert_equal true, result
  end

  # SECURITY TESTS

  test "evaluate should reject unsafe method names" do
    result = SafeConditionEvaluator.evaluate(@model, "system('ls')")
    assert_equal false, result # Should fail safely
  end

  test "evaluate should reject eval attempts" do
    result = SafeConditionEvaluator.evaluate(@model, "eval('1+1')")
    assert_equal false, result
  end

  test "evaluate should reject arbitrary code execution" do
    result = SafeConditionEvaluator.evaluate(@model, "destroy!")
    assert_equal false, result
  end

  test "evaluate should reject method_missing abuse" do
    result = SafeConditionEvaluator.evaluate(@model, "send('system', 'ls')")
    assert_equal false, result
  end

  test "evaluate should only accept whitelisted methods" do
    # Try a method not in the whitelist
    result = SafeConditionEvaluator.evaluate(@model, "unknown_method?")
    assert_equal false, result
  end

  # TOKENIZATION TESTS

  test "tokenize should extract method names correctly" do
    tokens = SafeConditionEvaluator.send(:tokenize, "editable? && reviewable?")
    assert_equal ["editable?", "&&", "reviewable?"], tokens
  end

  test "tokenize should extract NOT operator" do
    tokens = SafeConditionEvaluator.send(:tokenize, "!editable?")
    assert_equal ["!", "editable?"], tokens
  end

  test "tokenize should handle parentheses" do
    tokens = SafeConditionEvaluator.send(:tokenize, "(editable? || reviewable?) && validable?")
    assert_includes tokens, "("
    assert_includes tokens, ")"
  end

  # VALIDATION TESTS

  test "validate_tokens should accept all whitelisted methods" do
    SafeConditionEvaluator::SAFE_METHODS.each do |method|
      assert_nothing_raised do
        SafeConditionEvaluator.send(:validate_tokens!, [method])
      end
    end
  end

  test "validate_tokens should accept all whitelisted operators" do
    SafeConditionEvaluator::SAFE_OPERATORS.each do |operator|
      assert_nothing_raised do
        SafeConditionEvaluator.send(:validate_tokens!, [operator])
      end
    end
  end

  test "validate_tokens should raise SecurityError for unsafe methods" do
    assert_raises(SecurityError) do
      SafeConditionEvaluator.send(:validate_tokens!, ["system"])
    end
  end

  test "validate_tokens should raise SecurityError for eval" do
    assert_raises(SecurityError) do
      SafeConditionEvaluator.send(:validate_tokens!, ["eval"])
    end
  end

  # ERROR HANDLING TESTS

  test "evaluate should fail safely on NoMethodError" do
    # Mock a model without the method
    model_without_method = Object.new
    result = SafeConditionEvaluator.evaluate(model_without_method, "editable?")
    assert_equal false, result # Should fail safely
  end

  test "evaluate should log error on failure" do
    Rails.logger.expects(:error).with(regexp_matches(/SafeConditionEvaluator error/))
    SafeConditionEvaluator.evaluate(@model, "invalid_syntax &&& broken")
  end

  # INTEGRATION TESTS

  test "instance method evaluate_condition should work" do
    @model.editable = true
    result = @model.evaluate_condition("editable?")
    assert_equal true, result
  end

  test "evaluate should handle whitespace in conditions" do
    @model.editable = true
    @model.reviewable = true
    result = SafeConditionEvaluator.evaluate(@model, "  editable?  &&  reviewable?  ")
    assert_equal true, result
  end

  # REAL-WORLD SCENARIO TESTS

  test "evaluate should handle typical wizard condition: persisted?" do
    result = SafeConditionEvaluator.evaluate(@model, "persisted?")
    assert_equal true, result
  end

  test "evaluate should handle typical wizard condition: editable? && !reviewable?" do
    @model.editable = true
    @model.reviewable = false
    result = SafeConditionEvaluator.evaluate(@model, "editable? && !reviewable?")
    assert_equal true, result
  end

  test "evaluate should handle typical wizard condition: validable? || reviewable?" do
    @model.validable = false
    @model.reviewable = true
    result = SafeConditionEvaluator.evaluate(@model, "validable? || reviewable?")
    assert_equal true, result
  end
end
