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
      return unless target.respond_to?(:rotate)

      rotate_data = target.rotate
      return unless rotate_data && rotate_data[@attachment.name].present?

      " -rotate #{rotate_data[@attachment.name]} "
    end
  end
end
