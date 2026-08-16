# frozen_string_literal: true

module Gamification
  # ==================================
  # Proposal Event Listener
  # ==================================
  # Awards points for proposal-related actions
  # ==================================

  class ProposalListener
    POINTS_CONFIG = {
      created: 50,
      approved: 100,
      featured: 200,
      implemented: 500
    }.freeze

    REASONS = {
      created: 'Propuesta creada',
      approved: 'Propuesta aprobada',
      featured: 'Propuesta destacada',
      implemented: '¡Propuesta implementada!'
    }.freeze

    class << self
      def register!
        EventBus.instance.subscribe('proposal.created', method(:on_proposal_created))
        EventBus.instance.subscribe('proposal.approved', method(:on_proposal_approved))
        EventBus.instance.subscribe('proposal.featured', method(:on_proposal_featured))
        EventBus.instance.subscribe('proposal.implemented', method(:on_proposal_implemented))
      end

      def on_proposal_created(event)
        award(event, :created, award_badges: true)
      end

      def on_proposal_approved(event)
        award(event, :approved, award_badges: true)
      end

      def on_proposal_featured(event)
        award(event, :featured)
      end

      def on_proposal_implemented(event)
        award(event, :implemented, award_badges: true)
      end

      private

      # Los eventos aprobado/destacado/implementado resolvian el usuario con
      # `proposal.author`, pero `author` es una columna de texto con el nombre de
      # quien publicó (importado de Reddit), no una asociación: UserStats.for_user
      # recibía una String y reventaba. Proposal no tiene relación con User, así
      # que el usuario solo puede venir en el propio evento.
      #
      # El payload se normaliza porque puede llegar con claves de texto, por
      # ejemplo si el evento viaja serializado a través de una cola.
      def award(event, kind, award_badges: false)
        event = normalize(event)
        user = resolve_user(event)
        return if user.nil?

        # find (y no find_by): un evento que apunte a una propuesta inexistente es
        # un error que debe aflorar, no silenciarse.
        proposal = Proposal.find(event[:proposal_id])

        UserStats.for_user(user).earn_points!(
          POINTS_CONFIG[kind],
          reason: REASONS[kind],
          source: proposal
        )

        BadgeAwarder.check_and_award!(user) if award_badges
      end

      def normalize(event)
        return {} if event.nil?

        event.respond_to?(:symbolize_keys) ? event.symbolize_keys : event
      end

      def resolve_user(event)
        # Sin user_id no se puede atribuir la puntuacion y se ignora el evento;
        # con un user_id que no existe se deja aflorar el RecordNotFound, igual
        # que con la propuesta.
        return nil if event[:user_id].blank?

        User.find(event[:user_id])
      end
    end
  end
end
