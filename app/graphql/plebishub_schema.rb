# frozen_string_literal: true

# ================================================================
# PlebisHub GraphQL Schema - PlebisHub 2.0
# ================================================================
# Main GraphQL schema for the PlebisHub platform
# Provides flexible querying, mutations, and real-time subscriptions
# ================================================================

class PlebishubSchema < GraphQL::Schema
  # Queries
  query(Types::QueryType)

  # Mutations
  mutation(Types::MutationType)

  # Subscriptions for real-time updates
  subscription(Types::SubscriptionType)

  # Use batch loading to avoid N+1 queries
  use GraphQL::Batch

  # Dataloader for advanced batching
  use GraphQL::Dataloader

  # Error handling
  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, "#{field.type.unwrap.graphql_name} not found"
  end

  rescue_from(Pundit::NotAuthorizedError) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, "Not authorized to access this resource"
  end

  rescue_from(ActiveRecord::RecordInvalid) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, err.record.errors.full_messages.join(", ")
  end

  # Max query depth to prevent malicious queries
  max_depth 15

  # Max complexity to prevent expensive queries
  max_complexity 300

  # Query timeout
  query_timeout 10.seconds

  # Rate limiting per user
  def self.id_from_object(object, type_definition, query_ctx)
    # Generate GraphQL ID: Base64.encode("ClassName:id")
    GraphQL::Schema::UniqueWithinType.encode(object.class.name, object.id)
  end

  def self.object_from_id(id, query_ctx)
    # Decode GraphQL ID and fetch object
    class_name, item_id = GraphQL::Schema::UniqueWithinType.decode(id)
    class_name.constantize.find(item_id)
  end

  def self.resolve_type(abstract_type, object, context)
    # Resolve interface/union types
    case object
    when User
      Types::UserType
    when Proposal
      Types::ProposalType
    when Vote
      Types::VoteType
    else
      raise "Unexpected object: #{object.inspect}"
    end
  end

  # Introspection for development/staging only
  def self.introspection_enabled?
    !Rails.env.production? || ENV['GRAPHQL_INTROSPECTION'] == 'true'
  end

  disable_introspection_entry_points unless introspection_enabled?

  # Default value for arguments
  argument_class Types::BaseArgument

  # Default value for fields
  field_class Types::BaseField

  # Default value for objects
  object_class Types::BaseObject

  # Default value for interfaces
  interface_class Types::BaseInterface

  # Default value for unions
  union_class Types::BaseUnion

  # Default value for enums
  enum_class Types::BaseEnum

  # Default value for scalars
  scalar_class Types::BaseScalar
end
