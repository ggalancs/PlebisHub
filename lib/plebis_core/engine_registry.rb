# frozen_string_literal: true

module PlebisCore
  # EngineRegistry
  #
  # Central registry of all available engines in the application.
  # Provides metadata about each engine including name, description,
  # version, models, controllers, dependencies, and default configuration.
  #
  # This registry is used by EngineActivation to validate engines and
  # by ActiveAdmin to display engine information.
  #
  class EngineRegistry
    # Registry of all available engines
    # Each engine has metadata about its components and dependencies
    ENGINES = {
      'plebis_cms' => {
        name: 'Content Management',
        description: 'Blog posts, pages, and notifications',
        version: '1.0.0',
        models: %w[Post Category Page Notice NoticeRegistrar],
        controllers: %w[BlogController PageController NoticeController],
        dependencies: ['User'],
        default_config: {
          wordpress_api_enabled: false,
          push_notifications_enabled: true
        }
      },
      'plebis_participation' => {
        name: 'Participation Teams',
        description: 'Citizen participation teams and working groups',
        version: '1.0.0',
        models: %w[ParticipationTeam],
        controllers: %w[ParticipationTeamsController],
        dependencies: ['User'],
        default_config: {}
      },
      'plebis_proposals' => {
        name: 'Citizen Proposals',
        description: 'Citizen proposal submission and support system',
        version: '1.0.0',
        models: %w[Proposal Support],
        controllers: %w[ProposalsController SupportsController],
        dependencies: ['User'],
        default_config: {
          reddit_integration_enabled: false
        }
      },
      'plebis_impulsa' => {
        name: 'Impulsa Projects',
        description: 'Citizen project submission and evaluation platform',
        version: '1.0.0',
        models: %w[ImpulsaEdition ImpulsaEditionCategory ImpulsaEditionTopic
                   ImpulsaProject ImpulsaProjectStateTrans ImpulsaProjectTopic],
        controllers: %w[ImpulsaController],
        dependencies: ['User'],
        default_config: {
          max_file_size_mb: 10,
          allowed_file_types: ['pdf', 'doc', 'docx'],
          evaluation_enabled: true
        }
      },
      'plebis_verification' => {
        name: 'User Verification',
        description: 'Identity verification system with document and SMS validation',
        version: '1.0.0',
        models: %w[UserVerification],
        controllers: %w[UserVerificationsController SmsValidatorController],
        dependencies: ['User'],
        default_config: {
          sms_verification_enabled: true,
          document_verification_enabled: true,
          require_photos: true
        }
      },
      'plebis_voting' => {
        name: 'Electronic Voting',
        description: 'Democratic voting system with electronic and paper ballots',
        version: '1.0.0',
        models: %w[Election ElectionLocation ElectionLocationQuestion
                   Vote VoteCircle VoteCircleType],
        controllers: %w[VoteController],
        dependencies: ['User', 'plebis_verification'],
        default_config: {
          nvotes_api_url: '',
          allow_paper_voting: true,
          sms_verification_required: true
        }
      },
      'plebis_microcredit' => {
        name: 'Microcréditos',
        description: 'Microcredit campaign management and loan tracking',
        version: '1.0.0',
        models: %w[Microcredit MicrocreditLoan MicrocreditOption],
        controllers: %w[MicrocreditController],
        dependencies: ['User'],
        default_config: {
          allow_renewals: true,
          max_loan_amount: 10000
        }
      },
      'plebis_collaborations' => {
        name: 'Colaboraciones',
        description: 'Economic collaboration and donation management',
        version: '1.0.0',
        models: %w[Collaboration Order],
        controllers: %w[CollaborationsController OrdersController],
        dependencies: ['User'],
        default_config: {
          payment_gateway: 'redsys',
          sepa_enabled: true,
          min_amount: 3
        }
      },
      'plebis_militant' => {
        name: 'Gestión de Militancia',
        description: 'Militant status tracking and management',
        version: '1.0.0',
        models: %w[MilitantRecord],
        controllers: %w[MilitantController],
        dependencies: ['User', 'plebis_collaborations', 'plebis_verification'],
        default_config: {
          min_militant_amount: 3,
          external_api_enabled: true
        }
      }
    }.freeze

    # Get list of all available engine names
    # @return [Array<String>] Array of engine names
    #
    def self.available_engines
      ENGINES.keys
    end

    # Get information about a specific engine
    # @param engine_name [String] The engine name
    # @return [Hash] Engine metadata
    #
    def self.info(engine_name)
      ENGINES[engine_name] || {}
    end

    # Get dependencies for an engine
    # @param engine_name [String] The engine name
    # @return [Array<String>] Array of dependency names
    #
    def self.dependencies_for(engine_name)
      info(engine_name)[:dependencies] || []
    end

    # Check if an engine can be enabled
    # Verifies that all dependencies are met
    # @param engine_name [String] The engine name
    # @return [Boolean] Whether the engine can be enabled
    #
    def self.can_enable?(engine_name)
      deps = dependencies_for(engine_name)

      # Verify that dependencies are active
      deps.all? do |dep|
        # 'User' is always available (core model)
        dep == 'User' || EngineActivation.enabled?(dep)
      end
    rescue => e
      Rails.logger.error "[EngineRegistry] Error checking if #{engine_name} can be enabled: #{e.message}"
      false
    end

    # Get default configuration for an engine
    # @param engine_name [String] The engine name
    # @return [Hash] Default configuration
    #
    def self.default_config(engine_name)
      info(engine_name)[:default_config] || {}
    end

    # Validate that an engine exists
    # @param engine_name [String] The engine name
    # @return [Boolean] Whether the engine exists
    #
    def self.exists?(engine_name)
      ENGINES.key?(engine_name)
    end

    # Get all engines that depend on a given engine
    # @param engine_name [String] The engine name
    # @return [Array<String>] Array of dependent engine names
    #
    def self.dependents_of(engine_name)
      ENGINES.select do |_name, metadata|
        metadata[:dependencies].include?(engine_name)
      end.keys
    end

    # Get engines grouped by their status
    # @return [Hash] Hash with :enabled and :disabled arrays
    #
    def self.engines_by_status
      {
        enabled: EngineActivation.where(enabled: true).pluck(:engine_name),
        disabled: EngineActivation.where(enabled: false).pluck(:engine_name)
      }
    rescue => e
      Rails.logger.error "[EngineRegistry] Error getting engines by status: #{e.message}"
      { enabled: [], disabled: [] }
    end
  end
end
