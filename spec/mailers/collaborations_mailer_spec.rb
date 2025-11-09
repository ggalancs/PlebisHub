# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollaborationsMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }
  let(:collaboration) { create(:collaboration, :incomplete, user: user) }

  describe 'collaboration_suspended_militant' do
    let(:mail) { described_class.collaboration_suspended_militant(collaboration) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to be_present
    end

    it 'incluye mensaje sobre devoluciones de recibos' do
      expect(mail.body.encoded).to match(/devoluciones de recibos/)
    end

    it 'incluye email de colaboraciones' do
      expect(mail.body.encoded).to include('colaboraciones@plebisbrand.info')
    end

    it 'incluye saludo cordial' do
      expect(mail.body.encoded).to match(/cordial saludo/)
    end
  end

  describe 'collaboration_suspended_user' do
    let(:mail) { described_class.collaboration_suspended_user(collaboration) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje sobre suspensión' do
      expect(mail.body.encoded).to match(/suspendi|devoluc/)
    end
  end

  describe 'creditcard_error_email' do
    let(:mail) { described_class.creditcard_error_email(collaboration) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje sobre error de tarjeta' do
      expect(mail.body.encoded).to match(/tarjeta|TPV|rechazado/)
    end

    it 'incluye email de administración' do
      expect(mail.body.encoded).to include('administración@plebisbrand.info')
    end

    it 'incluye teléfono de contacto' do
      expect(mail.body.encoded).to match(/917376825/)
    end
  end

  describe 'creditcard_expired_email' do
    let(:mail) { described_class.creditcard_expired_email(collaboration) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje sobre tarjeta caducada' do
      expect(mail.body.encoded).to match(/caducad|expirad/)
    end
  end

  describe 'order_returned_militant' do
    let(:mail) { described_class.order_returned_militant(collaboration) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje para militante' do
      expect(mail.body.encoded).to match(/militant|recibo|devol/)
    end
  end

  describe 'order_returned_user' do
    let(:mail) { described_class.order_returned_user(collaboration) }

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje sobre devolución' do
      expect(mail.body.encoded).to match(/devol|recibo/)
    end
  end
end
