# frozen_string_literal: true

# WickedPdf Configuration
# Updated to use the new configure block syntax (WickedPdf 2.x+)
WickedPdf.configure do |config|
  config.exe_path = '/usr/bin/wkhtmltopdf-proxy'
end
