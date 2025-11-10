# frozen_string_literal: true

namespace :engines do
  desc "List all available engines"
  task list: :environment do
    puts "\nAvailable Engines:"
    puts "-" * 80

    EngineActivation.order(:engine_name).each do |ea|
      status = ea.enabled? ? "✓ ACTIVE" : "✗ inactive"
      puts sprintf("%-30s %s", ea.engine_name, status)
      puts "  #{ea.description}" if ea.description.present?
    end

    puts "-" * 80
    puts "Total: #{EngineActivation.count} engines"
    puts "  - Active: #{EngineActivation.where(enabled: true).count}"
    puts "  - Inactive: #{EngineActivation.where(enabled: false).count}"
  end

  desc "Enable an engine"
  task :enable, [:engine_name] => :environment do |t, args|
    engine_name = args[:engine_name]

    unless engine_name
      puts "Usage: rake engines:enable[engine_name]"
      exit 1
    end

    unless PlebisCore::EngineRegistry.exists?(engine_name)
      puts "✗ Engine '#{engine_name}' does not exist"
      puts "\nAvailable engines:"
      PlebisCore::EngineRegistry.available_engines.each { |e| puts "  - #{e}" }
      exit 1
    end

    if PlebisCore::EngineRegistry.can_enable?(engine_name)
      EngineActivation.enable!(engine_name)
      puts "✓ Engine '#{engine_name}' enabled"
      puts "\n⚠️ IMPORTANT: You MUST restart the application for changes to take effect"
      puts "   Run: touch tmp/restart.txt  (Passenger)"
      puts "   Or restart your Rails server manually"
    else
      # Cache enabled engines to avoid N+1 queries
      enabled_engines = EngineActivation.where(enabled: true).pluck(:engine_name).to_set
      deps = PlebisCore::EngineRegistry.dependencies_for(engine_name)
      missing = deps.reject { |d| d == 'User' || enabled_engines.include?(d) }
      puts "✗ Cannot enable '#{engine_name}'. Missing dependencies: #{missing.join(', ')}"
      puts "\nPlease enable the following engines first:"
      missing.each { |d| puts "  - #{d}" }
      exit 1
    end
  end

  desc "Disable an engine"
  task :disable, [:engine_name] => :environment do |t, args|
    engine_name = args[:engine_name]

    unless engine_name
      puts "Usage: rake engines:disable[engine_name]"
      exit 1
    end

    # Cache enabled engines to avoid N+1 queries
    enabled_engines = EngineActivation.where(enabled: true).pluck(:engine_name).to_set

    # Check if any enabled engine depends on this one
    dependents = PlebisCore::EngineRegistry.dependents_of(engine_name)
    enabled_dependents = dependents.select { |d| enabled_engines.include?(d) }

    if enabled_dependents.any?
      puts "✗ Cannot disable '#{engine_name}'. These engines depend on it:"
      enabled_dependents.each { |d| puts "  - #{d}" }
      puts "\nPlease disable dependent engines first"
      exit 1
    end

    EngineActivation.disable!(engine_name)
    puts "✓ Engine '#{engine_name}' disabled"
    puts "\n⚠️ IMPORTANT: You MUST restart the application for changes to take effect"
    puts "   Run: touch tmp/restart.txt  (Passenger)"
    puts "   Or restart your Rails server manually"
  end

  desc "Show engine info"
  task :info, [:engine_name] => :environment do |t, args|
    engine_name = args[:engine_name]

    unless engine_name
      puts "Usage: rake engines:info[engine_name]"
      exit 1
    end

    info = PlebisCore::EngineRegistry.info(engine_name)

    if info.empty?
      puts "✗ Engine '#{engine_name}' not found"
      exit 1
    end

    activation = EngineActivation.find_by(engine_name: engine_name)

    puts "\nEngine: #{engine_name}"
    puts "-" * 80
    puts "Name:        #{info[:name]}"
    puts "Description: #{info[:description]}"
    puts "Version:     #{info[:version]}"
    puts "Status:      #{activation&.enabled? ? '✓ ACTIVE' : '✗ inactive'}"
    puts "\nComponents:"
    puts "  Models:      #{info[:models].join(', ')}"
    puts "  Controllers: #{info[:controllers].join(', ')}"
    puts "\nDependencies:"
    deps = info[:dependencies] || []
    if deps.empty?
      puts "  None"
    else
      # Cache enabled engines to avoid N+1 queries
      enabled_engines = EngineActivation.where(enabled: true).pluck(:engine_name).to_set
      deps.each do |dep|
        status = (dep == 'User' || enabled_engines.include?(dep)) ? '✓' : '✗'
        puts "  #{status} #{dep}"
      end
    end

    if activation
      puts "\nConfiguration:"
      if activation.configuration.empty?
        puts "  (using defaults)"
      else
        activation.configuration.each do |key, value|
          puts "  #{key}: #{value}"
        end
      end
    end
    puts "-" * 80
  end

  desc "Verify engine dependencies"
  task verify: :environment do
    puts "\nVerifying Engine Dependencies:"
    puts "-" * 80

    has_errors = false

    # Cache enabled engines to avoid N+1 queries
    enabled_engines = EngineActivation.where(enabled: true).pluck(:engine_name).to_set

    EngineActivation.where(enabled: true).each do |ea|
      deps = PlebisCore::EngineRegistry.dependencies_for(ea.engine_name)
      missing = deps.reject { |d| d == 'User' || enabled_engines.include?(d) }

      if missing.any?
        puts "✗ #{ea.engine_name}: MISSING #{missing.join(', ')}"
        has_errors = true
      else
        puts "✓ #{ea.engine_name}: OK"
      end
    end

    puts "-" * 80

    if has_errors
      puts "\n⚠ Some engines have missing dependencies!"
      exit 1
    else
      puts "\n✓ All engine dependencies are satisfied"
    end
  end

  desc "Seed engine activations"
  task seed: :environment do
    puts "\nSeeding EngineActivations..."
    puts "-" * 80

    EngineActivation.seed_all

    puts "✓ Created #{EngineActivation.count} engine activation records"
    puts "  - Active: #{EngineActivation.where(enabled: true).count}"
    puts "  - Inactive: #{EngineActivation.where(enabled: false).count}"
    puts "-" * 80
  end

  desc "Show engine dependency graph"
  task graph: :environment do
    puts "\nEngine Dependency Graph:"
    puts "=" * 80

    # Cache all activations to avoid N+1 queries
    activations_by_name = EngineActivation.all.index_by(&:engine_name)
    enabled_engines = activations_by_name.select { |_, a| a.enabled? }.keys.to_set

    PlebisCore::EngineRegistry.available_engines.sort.each do |engine_name|
      info = PlebisCore::EngineRegistry.info(engine_name)
      deps = info[:dependencies] || []
      activation = activations_by_name[engine_name]
      status = activation&.enabled? ? '✓' : '✗'

      puts "\n#{status} #{engine_name}"
      if deps.any? && deps != ['User']
        deps.reject { |d| d == 'User' }.each do |dep|
          dep_status = enabled_engines.include?(dep) ? '✓' : '✗'
          puts "  └─> #{dep_status} #{dep}"
        end
      else
        puts "  └─> (no dependencies)"
      end

      # Show what depends on this engine
      dependents = PlebisCore::EngineRegistry.dependents_of(engine_name)
      if dependents.any?
        puts "  ┌─< Required by:"
        dependents.each do |dependent|
          dep_status = enabled_engines.include?(dependent) ? '✓' : '✗'
          puts "  │   #{dep_status} #{dependent}"
        end
      end
    end

    puts "\n" + "=" * 80
    puts "Legend: ✓ = enabled, ✗ = disabled"
    puts "=" * 80
  end
end
