# frozen_string_literal: true

# Backward compatibility aliases for PLEBIS_VOTES engine
# These aliases allow existing code to reference models without the namespace
# After full migration, these can be removed

# Models
Election = PlebisVotes::Election unless defined?(Election)
ElectionLocation = PlebisVotes::ElectionLocation unless defined?(ElectionLocation)
ElectionLocationQuestion = PlebisVotes::ElectionLocationQuestion unless defined?(ElectionLocationQuestion)
Vote = PlebisVotes::Vote unless defined?(Vote)
VoteCircle = PlebisVotes::VoteCircle unless defined?(VoteCircle)
VoteCircleType = PlebisVotes::VoteCircleType unless defined?(VoteCircleType)

# Services
PaperVoteService = PlebisVotes::PaperVoteService unless defined?(PaperVoteService)

# Concerns
TerritoryDetails = PlebisVotes::TerritoryDetails unless defined?(TerritoryDetails)

# Controllers (for route compatibility)
VoteController = PlebisVotes::VoteController unless defined?(VoteController)
