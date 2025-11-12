# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    # Automatically add errors field to all mutations
    field :errors, [String], null: false

    protected

    def current_user
      context[:current_user]
    end

    def authorize!(record = nil)
      raise GraphQL::ExecutionError, "Authentication required" unless current_user

      if record && !policy(record).send("#{context[:action]}?")
        raise GraphQL::ExecutionError, "Not authorized"
      end
    end

    def policy(record)
      # Use Pundit for authorization
      Pundit.policy!(current_user, record)
    end

    def success_response(resource)
      {
        resource.class.name.underscore.to_sym => resource,
        errors: []
      }
    end

    def error_response(resource)
      {
        resource.class.name.underscore.to_sym => nil,
        errors: resource.errors.full_messages
      }
    end

    # Publish domain events using EventBus
    def publish_event(event_name, payload = {})
      EventBus.instance.publish(event_name, payload)
    end
  end
end
