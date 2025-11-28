# frozen_string_literal: true

# Backward compatibility aliases for PLEBIS_VOTES engine
# These aliases allow existing code to reference models without the namespace
# After full migration, these can be removed

# Wrap in to_prepare to ensure classes are loaded after initialization
Rails.application.config.to_prepare do
  # Models
  Object.const_set(:Election, PlebisVotes::Election) unless defined?(Election)
  Object.const_set(:ElectionLocation, PlebisVotes::ElectionLocation) unless defined?(ElectionLocation)
  Object.const_set(:ElectionLocationQuestion, PlebisVotes::ElectionLocationQuestion) unless defined?(ElectionLocationQuestion)
  Object.const_set(:Vote, PlebisVotes::Vote) unless defined?(Vote)
  Object.const_set(:VoteCircle, PlebisVotes::VoteCircle) unless defined?(VoteCircle)
  Object.const_set(:VoteCircleType, PlebisVotes::VoteCircleType) unless defined?(VoteCircleType)

  # Services
  Object.const_set(:PaperVoteService, PlebisVotes::PaperVoteService) unless defined?(PaperVoteService)

  # Concerns
  Object.const_set(:TerritoryDetails, PlebisVotes::TerritoryDetails) unless defined?(TerritoryDetails)

  # Controllers (for route compatibility)
  Object.const_set(:VoteController, PlebisVotes::VoteController) unless defined?(VoteController)
end
