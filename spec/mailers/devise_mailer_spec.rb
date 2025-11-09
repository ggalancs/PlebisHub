# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Mailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }

  before do
    I18n.locale = :es
    ActionMailer::Base.default_url_options = { host: 'www.example.com', protocol: 'http' }
  end

  describe 'confirmation_instructions' do
    let(:token) { 'fake_confirmation_token' }
    let(:mail) { described_class.confirmation_instructions(user, token) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to be_present
    end

    it 'incluye el email del usuario' do
      expect(mail.html_part.body.decoded).to include(user.email)
    end

    it 'incluye el token de confirmación en el enlace' do
      expect(mail.html_part.body.decoded).to match(/confirmation_token=#{token}/)
    end
  end

  describe 'reset_password_instructions' do
    let(:token) { 'fake_reset_token' }
    let(:mail) { described_class.reset_password_instructions(user, token) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to be_present
    end

    it 'incluye el email del usuario' do
      expect(mail.html_part.body.decoded).to include(user.email)
    end

    it 'incluye el token de reset en el enlace' do
      expect(mail.html_part.body.decoded).to match(/reset_password_token=#{token}/)
    end

    it 'incluye información sobre cambio de contraseña' do
      expect(mail.html_part.body.decoded).to match(/password|contraseña/i)
    end
  end

  describe 'unlock_instructions' do
    let(:token) { 'fake_unlock_token' }
    let(:mail) { described_class.unlock_instructions(user, token) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to be_present
    end

    it 'incluye el email del usuario' do
      expect(mail.html_part.body.decoded).to include(user.email)
    end

    it 'incluye el token de desbloqueo en el enlace' do
      expect(mail.html_part.body.decoded).to match(/unlock_token=#{token}/)
    end

    it 'incluye información sobre desbloqueo' do
      expect(mail.html_part.body.decoded).to match(/unlock|desbloqueo/i)
    end
  end
end
