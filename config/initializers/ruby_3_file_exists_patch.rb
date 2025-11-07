# frozen_string_literal: true

# Monkey patch for Ruby 3.x compatibility
# File.exists? was removed in Ruby 3.2, but many older gems still use it
# This patch adds it back as an alias to File.exist?

class File
  class << self
    alias_method :exists?, :exist? unless respond_to?(:exists?)
  end
end unless File.respond_to?(:exists?)
