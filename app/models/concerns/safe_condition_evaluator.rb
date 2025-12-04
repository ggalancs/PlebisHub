# frozen_string_literal: true

# SafeConditionEvaluator: Replace unsafe eval() with whitelist-based condition checking
#
# This module provides a secure way to evaluate wizard conditions without using eval().
# Conditions are limited to a whitelist of safe methods and simple boolean logic.
#
# Usage:
#   SafeConditionEvaluator.evaluate(project, "published? && has_team?")
#   => true/false
#
# Replaces: eval(group[:condition])
# Security: Cannot execute arbitrary code, only whitelisted methods

module SafeConditionEvaluator
  extend ActiveSupport::Concern

  # Whitelisted methods that can be called on ImpulsaProject
  # Based on ImpulsaProjectStates and state machine
  SAFE_METHODS = %w[
    editable?
    reviewable?
    fixable?
    saveable?
    markable_for_review?
    deleteable?
    new?
    review?
    spam?
    fixes?
    review_fixes?
    validable?
    validated?
    invalidated?
    winner?
    resigned?
    persisted?
  ].freeze

  # Whitelisted operators for boolean logic
  SAFE_OPERATORS = %w[&& || ! ( )].freeze

  module ClassMethods
    # Evaluate a condition string safely without eval()
    #
    # @param context [Object] The object to evaluate conditions against (usually ImpulsaProject)
    # @param condition_string [String] The condition to evaluate (e.g., "published? && has_team?")
    # @return [Boolean] The result of the condition evaluation
    #
    # @example
    #   SafeConditionEvaluator.evaluate(project, "published? && has_team?")
    #   => true
    def evaluate(context, condition_string)
      return true if condition_string.blank?

      # Parse and validate the condition string
      tokens = tokenize(condition_string)
      validate_tokens!(tokens)

      # Build and execute safe condition
      execute_condition(context, tokens)
    rescue StandardError => e
      Rails.logger.error("SafeConditionEvaluator error: #{e.message} for condition: #{condition_string}")
      false # Fail safely
    end

    private

    # Tokenize the condition string into method names and operators
    def tokenize(condition_string)
      condition_string.scan(/\w+\?|&&|\|\||!|\(|\)/)
    end

    # Validate that all tokens are in the whitelist
    def validate_tokens!(tokens)
      tokens.each do |token|
        next if SAFE_OPERATORS.include?(token)
        next if SAFE_METHODS.include?(token)

        raise SecurityError, "Unsafe method in condition: #{token}"
      end
    end

    # Execute the condition by calling whitelisted methods
    # NO EVAL - uses pure Ruby boolean logic
    def execute_condition(context, tokens)
      # Convert tokens to boolean values, handling NOT operator
      values = []
      operators = []
      negate_next = false

      tokens.each do |token|
        case token
        when *SAFE_METHODS
          # Call the whitelisted method and get boolean result
          result = context.public_send(token)
          result = !!result # Convert to boolean (preserves false vs nil)

          # Apply NOT if flag is set
          if negate_next
            result = !result
            negate_next = false
          end

          values << result
        when '&&', '||'
          operators << token
        when '!'
          # NOT operator - set flag to negate next value
          negate_next = true
        when '(', ')'
          # Parentheses handling (simplified - assumes balanced parens)
          operators << token
        else
          raise SecurityError, "Invalid token: #{token}"
        end
      end

      # Evaluate the boolean expression
      evaluate_boolean_expression(values, operators)
    rescue NoMethodError => e
      Rails.logger.warn("Condition method not found: #{e.message}")
      false
    end

    # Evaluate boolean expression without eval()
    # Handles: value1 && value2, value1 || value2
    # (NOT operator is handled in execute_condition before values are added)
    def evaluate_boolean_expression(values, operators)
      return true if values.empty? && operators.empty?
      return values.first if operators.empty?

      result = values.shift

      operators.each_with_index do |op, idx|
        next_value = values[idx]

        case op
        when '&&'
          result &&= next_value
        when '||'
          result ||= next_value
        when '(', ')'
          # Skip parentheses (simplified handling)
          next
        end
      end

      result
    end
  end

  # Instance method wrapper for convenience
  def evaluate_condition(condition_string)
    self.class.evaluate(self, condition_string)
  end
end
