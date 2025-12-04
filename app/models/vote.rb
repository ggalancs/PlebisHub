# frozen_string_literal: true

class Vote < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :election
  belongs_to :paper_authority, class_name: 'User'

  validates :voter_id, presence: true
  validates :voter_id, uniqueness: { scope: :user_id }

  before_validation :save_voter_id, on: :create

  def generate_voter_id
    Digest::SHA256.hexdigest(
      (
        election.voter_id_template.presence ||
        '%<secret_key_base>s:%<user_id>s:%<election_id>s:%<scoped_agora_election_id>s'
      ) % voter_id_template_values
    )
  end

  def generate_message
    "#{voter_id}:AuthEvent:#{scoped_agora_election_id}:vote:#{Time.now.to_i}"
  end

  def generate_hash(message)
    key = election.server_shared_key
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('SHA256', 'sha256'), key, message)
  end

  def scoped_agora_election_id
    election.scoped_agora_election_id user
  end

  def url
    election.server_shared_key
    message = generate_message
    hash = generate_hash message
    "#{election.server_url}booth/#{scoped_agora_election_id}/vote/#{hash}/#{message}"
  end

  def test_url
    key = election.server_shared_key
    message = generate_message
    hash = generate_hash message
    "#{election.server_url}test_hmac/#{key}/#{hash}/#{message}"
  end

  private

  def save_voter_id
    if election && user
      # Rails 7.2: Set attributes directly in before_validation callback
      # Cannot use update_column here as record is not yet persisted
      self.agora_id = scoped_agora_election_id
      self.voter_id = generate_voter_id
    else
      errors.add(:voter_id, 'No se pudo generar')
    end
  end

  def voter_id_template_values
    @voter_id_template_values ||= Hash.new do |hash, key|
      hash[key] = case key
                  when :shared_secret then election.server_shared_key
                  when :normalized_vatid then normalized_vatid(!user.is_passport?, user.document_vatid)
                  when :secret_key_base then Rails.application.secrets.secret_key_base
                  when :user_id then user_id
                  when :election_id then election_id
                  when :scoped_agora_election_id then scoped_agora_election_id
                  else '%<key>s'
                  end
    end
  end

  def normalized_vatid(spanish_nif, document_vatid)
    (spanish_nif ? 'DNI' : 'PASS') + normalize_identifier(document_vatid)
  end

  def normalize_identifier(identifier)
    identifier.gsub(/[^a-zA-Z0-9]/, '')
              .upcase
              .each_char
              .chunk_while { |i, j| number?(i) == number?(j) }
              .map(&:join)
              .map { |part| part.gsub(/^0*/, '') }
              .join
  end

  NUMBERS = ('0'..'9').to_set
  def number?(char)
    NUMBERS.include?(char)
  end
end
