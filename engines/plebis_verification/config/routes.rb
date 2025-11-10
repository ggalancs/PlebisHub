# frozen_string_literal: true

PlebisVerification::Engine.routes.draw do
  # User verification routes
  scope :verificacion do
    get 'nueva', to: 'user_verifications#new', as: 'new_user_verification'
    post 'crear', to: 'user_verifications#create', as: 'user_verifications'
    get 'reporte', to: 'user_verifications#report', as: 'user_verification_report'
    get 'reporte_municipios', to: 'user_verifications#report_town', as: 'user_verification_report_town'
    get 'reporte_exterior', to: 'user_verifications#report_exterior', as: 'user_verification_report_exterior'
  end

  # SMS validation routes
  scope :validar_telefono do
    get 'paso1', to: 'sms_validator#step1', as: 'sms_validator_step1'
    get 'paso2', to: 'sms_validator#step2', as: 'sms_validator_step2'
    get 'paso3', to: 'sms_validator#step3', as: 'sms_validator_step3'
    post 'telefono', to: 'sms_validator#phone', as: 'sms_validator_phone'
    post 'captcha', to: 'sms_validator#captcha', as: 'sms_validator_captcha'
    post 'validar', to: 'sms_validator#valid', as: 'sms_validator_valid'
  end
end
