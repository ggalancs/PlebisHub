# frozen_string_literal: true

require 'csv'

# Service object to parse election census CSV files
# Extracts CSV parsing logic from VoteController
class CensusFileParser
  def initialize(election)
    @election = election
  end

  def find_user_by_validation_token(user_id, _validation_token)
    return nil if @election.census_file.blank?

    parse_csv do |row|
      return User.find_by(id: user_id) if row['user_id'] == user_id
    end

    nil
  end

  def find_user_by_document(document_vatid, document_type)
    return nil if @election.census_file.blank?

    parse_csv do |row|
      if row['dni']&.downcase == document_vatid.downcase
        return User.where('lower(document_vatid) = ?', document_vatid.downcase)
                   .find_by(document_type: document_type)
      end
    end

    nil
  end

  private

  def parse_csv
    # BUG: la gema paperclip ya no esta en el Gemfile y `Paperclip` no existe en
    # runtime, asi que esto lanzaba NameError y el parseo del censo estaba roto
    # por completo (voto en papel y elecciones con censo por CSV).
    # `census_file` es un adjunto de ActiveStorage desde la migracion.
    return nil unless @election.census_file.attached?

    data = CSV.parse(@election.census_file.download, headers: true)

    data.each do |row|
      result = yield(row)
      return result if result
    end

    nil
  end
end
