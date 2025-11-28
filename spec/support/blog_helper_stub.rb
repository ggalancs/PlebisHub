# frozen_string_literal: true

# Stub BlogHelper methods for testing
# The original BlogHelper uses auto_html gem which doesn't work properly in test environment
# This module prepends to BlogHelper to override the problematic methods

module BlogHelperTestOverride
  def formatted_content(post, max_paraphs = nil)
    content = post.content || ''

    if max_paraphs
      paraphs = content.split("\n", max_paraphs + 1)
      if paraphs.length > max_paraphs
        content = paraphs[0..(max_paraphs - 1)].join("\n")
        # Simplified version without auto_html
        return simple_format(content) + content_tag(:p, link_to('Seguir leyendo', post))
      end
    end

    # Return simple formatted content without auto_html processing
    simple_format(content)
  end

  def main_media(post)
    # Simplified version - just return empty string if no media_url
    # In production this would process YouTube/Vimeo/images via auto_html
    return nil unless post.respond_to?(:media_url) && post.media_url.present?

    # For testing, just wrap in a div
    content_tag(:div, post.media_url, class: 'media')
  end

  def long_date(post)
    # This one doesn't use auto_html, so we keep the original implementation
    I18n.l(post.created_at.to_date, format: :long)
  end
end

# Prepend the test override to BlogHelper to replace auto_html methods
# Check if the constant is defined before prepending to avoid autoloading issues
if Rails.env.test? && defined?(PlebisCms::BlogHelper)
  PlebisCms::BlogHelper.prepend(BlogHelperTestOverride)
end

