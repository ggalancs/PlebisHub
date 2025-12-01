# frozen_string_literal: true

module PlebisVerification
  class UserVerification < ApplicationRecord
    self.table_name = 'user_verifications'

    belongs_to :user, -> { with_deleted }

    has_paper_trail

    # ActiveStorage attachments (replaces Paperclip)
    has_one_attached :front_vatid
    has_one_attached :back_vatid

    # For rotation support (compatibility with old Paperclip processor)
    attr_accessor :front_vatid_rotation, :back_vatid_rotation

    def rotate
      @rotate ||= HashWithIndifferentAccess.new
    end

    # Variant for thumbnail (replaces Paperclip styles)
    def front_vatid_thumb
      return nil unless front_vatid.attached?
      front_vatid.variant(resize_to_limit: [450, 300], format: :png)
    end

    def back_vatid_thumb
      return nil unless back_vatid.attached?
      back_vatid.variant(resize_to_limit: [450, 300], format: :png)
    end

    validates :user, presence: true, unless: :not_require_photos?
    validate :front_vatid_presence, unless: :not_require_photos?
    validate :back_vatid_presence, if: :require_back?, unless: :not_require_photos?
    validates :terms_of_service, acceptance: { accept: [true, "1"] }

    validate :validate_image_content_types
    validate :validate_image_sizes

    private

    def front_vatid_presence
      errors.add(:front_vatid, :blank) unless front_vatid.attached?
    end

    def back_vatid_presence
      errors.add(:back_vatid, :blank) unless back_vatid.attached?
    end

    def validate_image_content_types
      if front_vatid.attached? && !front_vatid.content_type.start_with?('image/')
        errors.add(:front_vatid, 'debe ser una imagen')
      end
      if back_vatid.attached? && !back_vatid.content_type.start_with?('image/')
        errors.add(:back_vatid, 'debe ser una imagen')
      end
    end

    def validate_image_sizes
      if front_vatid.attached? && front_vatid.byte_size > 6.megabytes
        errors.add(:front_vatid, 'debe ser menor de 6MB')
      end
      if back_vatid.attached? && back_vatid.byte_size > 6.megabytes
        errors.add(:back_vatid, 'debe ser menor de 6MB')
      end
    end

    public

    #after_initialize :push_id_to_processing_list

    after_validation do
      errors.each do |attr|
        if attr.to_s.starts_with?("front_vatid_") || attr.to_s.starts_with?("back_vatid_")
          errors.delete(attr)
        end
      end
    end

    after_commit :verify_user_militant_status

    enum :status, {pending: 0, accepted: 1, issues: 2, rejected: 3, accepted_by_email: 4, discarded: 5, paused: 6}

    scope :verifying, -> { where status: [0, 2, 6] }
    scope :not_discarded, -> { where.not status: 5 }
    scope :discardable, -> { where status: [0, 2] }
    scope :not_sended, -> {where wants_card: true, born_at: nil  }

    def discardable?
      pending? || issues?
    end

    def require_back?
      !user.is_passport?
    end

    def not_require_photos?
      user.photos_unnecessary?
    end

    def self.for(user, params = {})
      current = self.where(user: user, status: [0, 2, 3]).first
      if current
        current.assign_attributes(params)
      else
        current = UserVerification.new params.merge(user: user)
      end
      current
    end

    def active?
      $redis = $redis || Redis::Namespace.new("plebisbrand_queue_validator", :redis => Redis.new)
      current_hash = $redis.hget(:processing,id)
      current_verification = UserVerification.find(id) if UserVerification.where(id: id).any?
      if current_verification && current_hash
        # convert hash in string to hash
        current_hash = current_hash.gsub(/[{}:]/,'').split(', ').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
        current_hash = Hash[current_hash.map{ |k, v| [k.to_sym, v] }]
        # end convert hash in string to hash
        DateTime.now.utc <= (current_hash[:locked_at].gsub(/[\"]/,'').gsub(/[|]/,':').to_datetime + Rails.application.secrets.user_verifications["time_to_expire_session"].minutes)
      else
        false
      end
    end

    def get_current_verifier
      $redis = $redis || Redis::Namespace.new("plebisbrand_queue_validator", :redis => Redis.new)
      current_hash = $redis.hget(:processing,id)
      if current_hash
        # convert hash in string to hash
        current_hash = current_hash.gsub(/[{}:]/,'').split(', ').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
        current_hash = Hash[current_hash.map{ |k, v| [k.to_sym, v] }]
        # end convert hash in string to hash
        User.find(current_hash[:author_id].to_i)
      else
        nil
      end
    end

    def verify_user_militant_status
      u = self.user
      u.update(militant: u.still_militant?)
      u.process_militant_data
    end

    # Determine appropriate status when creating/updating verification
    # Extracts business logic from controller
    def determine_initial_status
      # If photos are not necessary, automatically accept by email
      return :accepted_by_email if user.photos_unnecessary?

      # If previously rejected or had issues, reset to pending for resubmission
      return :pending if rejected? || issues?

      # Otherwise keep current status
      status
    end

    # Apply the determined status
    def apply_initial_status!
      self.status = determine_initial_status
    end
  end
end
