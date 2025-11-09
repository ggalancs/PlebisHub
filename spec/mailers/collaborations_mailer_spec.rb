# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollaborationsMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }
  let(:collaboration) { create(:collaboration, :incomplete, user: user) }

  # Mock Rails.application.secrets for mailers that use it
  before do
    I18n.locale = :es
    allow(Rails.application).to receive(:secrets).and_return(
      OpenStruct.new(
        microcredits: {
          'default_brand' => 'plebisbrand',
          'brands' => {
            'plebisbrand' => {
              'name' => 'PlebisBrand',
              'mail_signature' => 'Equipo PlebisBrand'
            }
          }
        }
      )
    )
  end

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
    let(:mail) { described_class.creditcard_error_email(user) }

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
    let(:mail) { described_class.creditcard_expired_email(user) }

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
    let(:order) { create(:order, :devuelta, collaboration: collaboration) }
    let(:mail) do
      # Ensure there's a returned order
      order
      described_class.order_returned_militant(collaboration)
    end

    before do
      # Mock Order.payment_day
      allow(Order).to receive(:payment_day).and_return(5)
    end

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje para militante' do
      expect(mail.body.encoded).to match(/devoluci|recibo|cuota/i)
    end
  end

  describe 'order_returned_user' do
    let(:order) { create(:order, :devuelta, collaboration: collaboration) }
    let(:mail) do
      # Ensure there's a returned order
      order
      described_class.order_returned_user(collaboration)
    end

    before do
      # Mock Order.payment_day
      allow(Order).to receive(:payment_day).and_return(5)
    end

    it 'renderiza el asunto' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'incluye mensaje sobre devolución' do
      expect(mail.body.encoded).to match(/devoluci|colaboraci/i)
    end
  end
end
