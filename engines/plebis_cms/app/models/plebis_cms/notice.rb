# frozen_string_literal: true

module PlebisCms
  class Notice < ApplicationRecord
    self.table_name = 'notices'

    validates :title, :body, presence: true
    validates :link, allow_blank: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }

    default_scope { order(created_at: :desc) }
    paginates_per 5

    # Scopes
    scope :sent, -> { where.not(sent_at: nil) }
    scope :pending, -> { where(sent_at: nil) }
    scope :active, -> { where('final_valid_at IS NULL OR final_valid_at > ?', Time.current) }
    scope :expired, -> { where('final_valid_at IS NOT NULL AND final_valid_at <= ?', Time.current) }

    def broadcast!
      broadcast_gcm(title, body, link)
      # Rails 7.2: Use update_column instead of deprecated update_attribute
      update_column(:sent_at, DateTime.current)
    end

    def broadcast_gcm(title, message, link)
      # TODO: lib / worker async
      require 'pushmeup'
      GCM.host = 'https://android.googleapis.com/gcm/send'
      GCM.format = :json
      GCM.key = Rails.application.secrets.gcm['key']

      data = { title: title, message: message, url: link, msgcnt: '1', soundname: 'beep.wav' }
      # for every 1000 devices we send only a notification
      PlebisCms::NoticeRegistrar.pluck(:registration_id).in_groups_of(1000) do |destination|
        GCM.send_notification(destination, data)
      end
    end

    def has_sent
      sent_at?
    end

    # Ruby convention: use ? for boolean methods
    alias sent? has_sent

    def active?
      final_valid_at.nil? || final_valid_at > Time.current
    end

    def expired?
      !active?
    end
  end
end
