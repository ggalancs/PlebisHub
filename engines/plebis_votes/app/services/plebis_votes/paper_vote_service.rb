# frozen_string_literal: true

module PlebisVotes
  # Service object to handle paper vote processing and logging
  # Extracts paper vote logic from VoteController
  class PaperVoteService
    def initialize(election, election_location, current_user)
      @election = election
      @election_location = election_location
      @current_user = current_user
      @tracking = Logger.new(Rails.root.join('log/paper_authorities.log').to_s)
    end

    def log_vote_query(document_type, document_vatid)
      @tracking.info "** #{@current_user.id} #{@current_user.full_name} ** QUERY: #{document_type} #{document_vatid}"
    end

    def log_vote_registered(paper_vote_user)
      @tracking.info "** #{@current_user.id} #{@current_user.full_name} ** VOTE: #{paper_vote_user.id}"
    end

    def save_vote_for_user(user)
      if @election.votes.create(user_id: user.id, paper_authority: @current_user)
        success_message
      else
        error_message
      end
    end

    private

    def success_message
      if @election.scope == 6
        { notice: 'Identificación registrada.' }
      else
        { notice: 'El voto ha sido registrado.' }
      end
    end

    def error_message
      { error: 'No se ha podido registrar el voto. Inténtalo nuevamente o consulta con la persona que administra el sistema.' }
    end
  end
end
