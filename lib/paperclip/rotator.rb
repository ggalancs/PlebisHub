# frozen_string_literal: true

module Paperclip
  class Rotator < Thumbnail
    def transformation_command
      if rotate_command
        rotate_command + super.join(' ')
      else
        super
      end
    end

    def rotate_command
      target = @attachment.instance
      return unless target.respond_to?(:rotate) && target.rotate[@attachment.name].present?

      " -rotate #{target.rotate[@attachment.name]} "
    end
  end
end
