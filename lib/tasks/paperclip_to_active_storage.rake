# frozen_string_literal: true

# Paperclip to ActiveStorage Migration
#
# This rake task migrates files from Paperclip storage to ActiveStorage.
# Run after updating models and running the ActiveStorage migration.
#
# Usage:
#   rails paperclip:migrate:all          # Migrate all models
#   rails paperclip:migrate:elections    # Migrate only Election model
#   rails paperclip:migrate:dry_run      # Show what would be migrated
#
# Important: Run this in a maintenance window as it may take time for large datasets.

namespace :paperclip do
  namespace :migrate do
    desc 'Dry run - show what would be migrated'
    task dry_run: :environment do
      puts '=' * 60
      puts 'Paperclip to ActiveStorage Migration - DRY RUN'
      puts '=' * 60
      puts ''

      migrations = [
        { model: 'Election', attachment: 'census_file', path_prefix: 'non-public/system/elections/census_files' },
        { model: 'PlebisVotes::Election', attachment: 'census_file',
          path_prefix: 'non-public/system/plebis_votes/elections/census_files' },
        { model: 'PlebisImpulsa::ImpulsaEdition',
          attachments: %w[schedule_model activities_resources_model requested_budget_model
                          monitoring_evaluation_model] },
        { model: 'PlebisVerification::UserVerification', attachments: %w[front_vatid back_vatid] },
        { model: 'PlebisMicrocredit::Microcredit', attachment: 'renewal_terms' }
      ]

      total_files = 0

      migrations.each do |migration|
        model_class = begin
          migration[:model].constantize
        rescue StandardError
          nil
        end
        next unless model_class

        attachments = migration[:attachments] || [migration[:attachment]]
        attachments.each do |attachment|
          count = begin
            model_class.where.not("#{attachment}_file_name" => nil).count
          rescue StandardError
            0
          end
          puts "#{migration[:model]}.#{attachment}: #{count} files"
          total_files += count
        end
      end

      puts ''
      puts "Total files to migrate: #{total_files}"
      puts ''
      puts "Run 'rails paperclip:migrate:all' to perform migration"
    end

    desc 'Migrate all Paperclip attachments to ActiveStorage'
    task all: :environment do
      puts '=' * 60
      puts 'Paperclip to ActiveStorage Migration'
      puts '=' * 60

      Rake::Task['paperclip:migrate:elections'].invoke
      Rake::Task['paperclip:migrate:impulsa_editions'].invoke
      Rake::Task['paperclip:migrate:user_verifications'].invoke
      Rake::Task['paperclip:migrate:microcredits'].invoke

      puts ''
      puts 'Migration complete!'
    end

    desc 'Migrate Election census files'
    task elections: :environment do
      puts "\nMigrating Election census files..."

      # Try main app model first, then engine model
      [Election, PlebisVotes::Election].each do |model_class|
        migrate_paperclip_attachment(
          model_class: model_class,
          attachment_name: :census_file,
          content_type_column: :census_file_content_type,
          file_name_column: :census_file_file_name,
          file_size_column: :census_file_file_size,
          updated_at_column: :census_file_updated_at
        )
      rescue NameError
        # Model not defined, skip
      end
    end

    desc 'Migrate ImpulsaEdition attachments'
    task impulsa_editions: :environment do
      puts "\nMigrating ImpulsaEdition attachments..."

      attachments = %w[schedule_model activities_resources_model requested_budget_model monitoring_evaluation_model]

      model_class = defined?(PlebisImpulsa::ImpulsaEdition) ? PlebisImpulsa::ImpulsaEdition : ImpulsaEdition

      attachments.each do |attachment|
        migrate_paperclip_attachment(
          model_class: model_class,
          attachment_name: attachment.to_sym,
          content_type_column: :"#{attachment}_content_type",
          file_name_column: :"#{attachment}_file_name",
          file_size_column: :"#{attachment}_file_size",
          updated_at_column: :"#{attachment}_updated_at"
        )
      end
    rescue NameError => e
      puts "Skipping ImpulsaEdition: #{e.message}"
    end

    desc 'Migrate UserVerification attachments'
    task user_verifications: :environment do
      puts "\nMigrating UserVerification attachments..."

      attachments = %w[front_vatid back_vatid]

      model_class = defined?(PlebisVerification::UserVerification) ? PlebisVerification::UserVerification : UserVerification

      attachments.each do |attachment|
        migrate_paperclip_attachment(
          model_class: model_class,
          attachment_name: attachment.to_sym,
          content_type_column: :"#{attachment}_content_type",
          file_name_column: :"#{attachment}_file_name",
          file_size_column: :"#{attachment}_file_size",
          updated_at_column: :"#{attachment}_updated_at"
        )
      end
    rescue NameError => e
      puts "Skipping UserVerification: #{e.message}"
    end

    desc 'Migrate Microcredit attachments'
    task microcredits: :environment do
      puts "\nMigrating Microcredit attachments..."

      model_class = defined?(PlebisMicrocredit::Microcredit) ? PlebisMicrocredit::Microcredit : Microcredit

      migrate_paperclip_attachment(
        model_class: model_class,
        attachment_name: :renewal_terms,
        content_type_column: :renewal_terms_content_type,
        file_name_column: :renewal_terms_file_name,
        file_size_column: :renewal_terms_file_size,
        updated_at_column: :renewal_terms_updated_at
      )
    rescue NameError => e
      puts "Skipping Microcredit: #{e.message}"
    end

    # Helper method to migrate a single Paperclip attachment to ActiveStorage
    def migrate_paperclip_attachment(model_class:, attachment_name:, content_type_column:, file_name_column:,
                                     file_size_column:, updated_at_column:)
      puts "  Migrating #{model_class.name}.#{attachment_name}..."

      # Check if model has the attachment columns
      unless model_class.column_names.include?(file_name_column.to_s)
        puts "    Skipping: column #{file_name_column} not found"
        return
      end

      # Find records with Paperclip files
      records = model_class.where.not(file_name_column => nil)
      total = records.count
      migrated = 0
      skipped = 0
      errors = 0

      records.find_each.with_index do |record, index|
        # Skip if already has ActiveStorage attachment
        if record.send(attachment_name).attached?
          skipped += 1
          next
        end

        begin
          # Build the Paperclip file path
          file_name = record.send(file_name_column)
          next if file_name.blank?

          # Paperclip path pattern: :rails_root/non-public/system/:class/:attachment/:id_partition/:filename
          id_partition = format('%09d', record.id).scan(/.{3}/).join('/')
          class_name = model_class.name.underscore.pluralize.gsub('/', '_')

          # Try multiple path patterns
          possible_paths = [
            Rails.root.join('non-public', 'system', class_name, attachment_name.to_s.pluralize, id_partition,
                            file_name),
            Rails.root.join('non-public', 'system', class_name, attachment_name.to_s, id_partition, file_name),
            Rails.public_path.join('system', class_name, attachment_name.to_s.pluralize, id_partition, file_name),
            Rails.public_path.join('system', class_name, attachment_name.to_s, id_partition, file_name),
            # For engine models
            Rails.root.join('non-public', 'system', model_class.table_name, attachment_name.to_s, id_partition,
                            file_name)
          ]

          file_path = possible_paths.find { |path| File.exist?(path) }

          unless file_path
            puts "    Warning: File not found for #{model_class.name}##{record.id}: #{file_name}"
            errors += 1
            next
          end

          # Get content type and attach to ActiveStorage
          content_type = record.send(content_type_column) || Marcel::MimeType.for(file_path)

          record.send(attachment_name).attach(
            io: File.open(file_path),
            filename: file_name,
            content_type: content_type
          )

          migrated += 1

          # Progress indicator
          puts "    Progress: #{index + 1}/#{total}" if ((index + 1) % 100).zero?
        rescue StandardError => e
          puts "    Error migrating #{model_class.name}##{record.id}: #{e.message}"
          errors += 1
        end
      end

      puts "    Completed: #{migrated} migrated, #{skipped} skipped (already migrated), #{errors} errors"
    end
  end

  namespace :cleanup do
    desc 'Remove old Paperclip columns after successful migration (DANGER: irreversible)'
    task columns: :environment do
      puts 'This task removes old Paperclip columns from the database.'
      puts 'Make sure you have:'
      puts '  1. Run paperclip:migrate:all successfully'
      puts '  2. Verified all files are accessible via ActiveStorage'
      puts '  3. Backed up your database'
      puts ''
      puts "Type 'YES I UNDERSTAND' to proceed:"

      input = $stdin.gets.chomp
      unless input == 'YES I UNDERSTAND'
        puts 'Aborted.'
        exit
      end

      # Generate migration to remove columns
      timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
      migration_file = Rails.root.join('db', 'migrate', "#{timestamp}_remove_paperclip_columns.rb")

      migration_content = <<~RUBY
        # frozen_string_literal: true

        # Generated by paperclip:cleanup:columns
        # This migration removes old Paperclip columns after migration to ActiveStorage
        class RemovePaperclipColumns < ActiveRecord::Migration[7.2]
          def change
            # Elections
            remove_column :elections, :census_file_file_name, :string
            remove_column :elections, :census_file_content_type, :string
            remove_column :elections, :census_file_file_size, :integer
            remove_column :elections, :census_file_updated_at, :datetime

            # ImpulsaEditions
            %w[schedule_model activities_resources_model requested_budget_model monitoring_evaluation_model].each do |attachment|
              remove_column :impulsa_editions, "\#{attachment}_file_name", :string
              remove_column :impulsa_editions, "\#{attachment}_content_type", :string
              remove_column :impulsa_editions, "\#{attachment}_file_size", :integer
              remove_column :impulsa_editions, "\#{attachment}_updated_at", :datetime
            end

            # ImpulsaEditionCategories (override files)
            %w[schedule_model_override activities_resources_model_override requested_budget_model_override monitoring_evaluation_model_override].each do |attachment|
              remove_column :impulsa_edition_categories, "\#{attachment}_file_name", :string
              remove_column :impulsa_edition_categories, "\#{attachment}_content_type", :string
              remove_column :impulsa_edition_categories, "\#{attachment}_file_size", :integer
              remove_column :impulsa_edition_categories, "\#{attachment}_updated_at", :datetime
            end

            # UserVerifications
            %w[front_vatid back_vatid].each do |attachment|
              remove_column :user_verifications, "\#{attachment}_file_name", :string
              remove_column :user_verifications, "\#{attachment}_content_type", :string
              remove_column :user_verifications, "\#{attachment}_file_size", :integer
              remove_column :user_verifications, "\#{attachment}_updated_at", :datetime
            end

            # Microcredits
            remove_column :microcredits, :renewal_terms_file_name, :string
            remove_column :microcredits, :renewal_terms_content_type, :string
            remove_column :microcredits, :renewal_terms_file_size, :integer
            remove_column :microcredits, :renewal_terms_updated_at, :datetime

            # ImpulsaProjects (many attachments)
            %w[logo endorsement register_entry statutes responsible_nif
               fiscal_obligations_certificate labor_obligations_certificate
               last_fiscal_year_report_of_activities last_fiscal_year_annual_accounts
               schedule activities_resources requested_budget monitoring_evaluation
               scanned_nif home_certificate bank_certificate
               evaluator1_analysis evaluator2_analysis].each do |attachment|
              remove_column :impulsa_projects, "\#{attachment}_file_name", :string
              remove_column :impulsa_projects, "\#{attachment}_content_type", :string
              remove_column :impulsa_projects, "\#{attachment}_file_size", :integer
              remove_column :impulsa_projects, "\#{attachment}_updated_at", :datetime
            end
          end
        end
      RUBY

      File.write(migration_file, migration_content)
      puts "Migration generated: #{migration_file}"
      puts 'Review and run: rails db:migrate'
    end

    desc 'Remove old Paperclip files after successful migration'
    task files: :environment do
      puts 'This will remove old Paperclip files from the filesystem.'
      puts 'Make sure you have verified all files are accessible via ActiveStorage.'
      puts ''
      puts 'Directories that would be removed:'

      paths = [
        Rails.root.join('non-public/system'),
        Rails.public_path.join('system')
      ]

      paths.each do |path|
        next unless Dir.exist?(path)

        size = begin
          `du -sh #{path} 2>/dev/null`.split("\t").first
        rescue StandardError
          'unknown'
        end
        puts "  #{path} (#{size})"
      end

      puts ''
      puts "Type 'DELETE FILES' to proceed:"

      input = $stdin.gets.chomp
      unless input == 'DELETE FILES'
        puts 'Aborted.'
        exit
      end

      paths.each do |path|
        if Dir.exist?(path)
          FileUtils.rm_rf(path)
          puts "Removed: #{path}"
        end
      end

      puts 'Cleanup complete.'
    end
  end
end
