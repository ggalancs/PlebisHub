# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVerificationMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }

  describe 'on_accepted' do
    let(:mail) { described_class.on_accepted(user.id) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('PlebisBrand, Datos verificados')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to include('verificaciones@soporte.plebisbrand.info')
    end

    it 'incluye mensaje sobre validación correcta' do
      expect(mail.body.encoded).to match(/validado correctamente|documento de identidad/)
    end

    it 'incluye agradecimiento por participar' do
      expect(mail.body.encoded).to match(/gracias por participar/)
    end

    it 'incluye saludo de PLEBISBRAND' do
      expect(mail.body.encoded).to match(/PLEBISBRAND/)
    end
  end

  describe 'on_rejected' do
    let(:mail) { described_class.on_rejected(user.id) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('PlebisBrand, no hemos podido realizar la verificación')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to include('verificaciones@soporte.plebisbrand.info')
    end

    it 'incluye mensaje sobre no poder completar validación' do
      expect(mail.body.encoded).to match(/no hemos podido|validaci/)
    end

    it 'incluye motivos habituales de rechazo' do
      expect(mail.body.encoded).to match(/motivos habituales/)
    end

    it 'incluye contacto LOPD' do
      expect(mail.body.encoded).to include('lopd@plebisbrand.info')
    end

    it 'incluye enlace a página de información' do
      expect(mail.body.encoded).to include('https://plebisbrand.info/identificate/')
    end
  end
end
