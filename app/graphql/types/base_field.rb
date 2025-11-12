# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    # Add authorization to fields
    def authorized?(object, args, context)
      # Check field-level permissions using Pundit
      return true if context[:current_user]&.admin?

      super
    end
  end
end
