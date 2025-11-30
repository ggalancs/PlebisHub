# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
# SECURITY FIX (SEC-020): Added additional sensitive fields to filter
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  :document_vatid,  # National ID
  :phone,           # Phone numbers
  :unconfirmed_phone,
  :born_at,         # Date of birth
  :address,         # Full address
  :postal_code,
  :iban,            # Bank account
  :payment_identifier
]
