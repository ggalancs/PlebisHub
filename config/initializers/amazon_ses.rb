# Use config.secrets (restored in config/application.rb for Rails 7.2+ compatibility)
if Rails.application.config.secrets&.dig(:aws_ses).present?
  aws_ses_config = Rails.application.config.secrets[:aws_ses]
  Aws::Rails.add_action_mailer_delivery_method(:ses,
    credentials: Aws::Credentials.new(
      aws_ses_config["access_key_id"],
      aws_ses_config["secret_access_key"]
   ), region: "eu-west-1")
end