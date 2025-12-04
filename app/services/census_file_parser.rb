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
    data = CSV.parse(
      Paperclip.io_adapters.for(@election.census_file).read,
      headers: true
    )

    data.each do |row|
      result = yield(row)
      return result if result
    end

    nil
  end
end
