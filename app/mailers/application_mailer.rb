# frozen_string_literal: true

# ApplicationMailer - Base mailer for all application mailers
class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets[:default_from_email] || 'noreply@example.com'
end
