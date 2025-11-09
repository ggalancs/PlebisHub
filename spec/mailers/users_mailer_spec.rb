# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }

  describe 'cancel_account_email' do
    let(:mail) { described_class.cancel_account_email(user.id) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('Te has dado de baja de PlebisBrand')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza BCC a bajas' do
      expect(mail.bcc).to include('bajas@plebisbrand.info')
    end

    it 'incluye nombre completo del usuario' do
      expect(mail.body.encoded).to include(user.full_name)
    end

    it 'incluye email del usuario' do
      expect(mail.body.encoded).to include(user.email)
    end

    it 'incluye documento del usuario' do
      expect(mail.body.encoded).to include(user.document_vatid)
    end

    it 'incluye mensaje de confirmación de baja' do
      expect(mail.body.encoded).to match(/confirmamos tu baja/)
    end

    it 'incluye contacto de protección de datos' do
      expect(mail.body.encoded).to include('protecciondedatos@plebisbrand.info')
    end
  end

  describe 'new_militant_email' do
    let(:mail) { described_class.new_militant_email(user.id) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('Enhorabuena, ya eres militante de PlebisBrand')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente' do
      expect(mail.from).to include('soportemilitantes@plebisbrand.info')
    end

    it 'incluye mensaje de bienvenida como militante' do
      expect(mail.body.encoded).to match(/ya eres militante/)
    end

    it 'incluye información sobre derechos como militante' do
      expect(mail.body.encoded).to match(/derechos|Círculo/)
    end

    it 'incluye enlace a información de militantes' do
      expect(mail.body.encoded).to include('plebisbrand.info/militantes')
    end
  end

  describe 'remember_email' do
    context 'cuando se busca por email' do
      let(:mail) { described_class.remember_email(:email, user.email) }

      it 'renderiza el asunto' do
        expect(mail.subject).to eq('[participa.plebisbrand.info] Has intentado registrarte de nuevo')
      end

      it 'renderiza el destinatario' do
        expect(mail.to).to include(user.email)
      end

      it 'incluye mensaje sobre intento de registro' do
        expect(mail.body.encoded).to match(/intentado crear un usuario/)
      end

      it 'incluye enlace para cambiar contraseña' do
        expect(mail.body.encoded).to match(/cambiarla|contraseña/)
      end

      it 'incluye enlace de ayuda' do
        expect(mail.body.encoded).to include('ayuda-para-acceder')
      end
    end

    context 'cuando se busca por document_vatid' do
      let(:mail) { described_class.remember_email(:document_vatid, user.document_vatid) }

      it 'renderiza el asunto' do
        expect(mail.subject).to eq('[participa.plebisbrand.info] Has intentado registrarte de nuevo')
      end

      it 'renderiza el destinatario' do
        expect(mail.to).to include(user.email)
      end
    end
  end

  describe 'microcredit_email (Spanish)' do
    let(:microcredit) { create(:microcredit, title: 'Test Microcredit #Campaign') }
    let(:loan) { create(:microcredit_loan, microcredit: microcredit, user: user, amount: 500, email: 'loan@example.com', first_name: 'Juan', last_name: 'García') }
    let(:brand_config) do
      {
        'name' => 'PlebisBrand',
        'mail_from' => 'microcreditos@plebisbrand.info',
        'mail_signature' => 'Equipo de Microcréditos'
      }
    end

    # Mock WickedPdf to avoid PDF generation in tests
    before do
      allow(WickedPdf).to receive(:new).and_return(double(pdf_from_string: 'fake_pdf_content'))
    end

    let(:mail) { described_class.microcredit_email(microcredit, loan, brand_config) }

    it 'renderiza el asunto con el nombre de la organización' do
      expect(mail.subject).to be_present
    end

    it 'renderiza el destinatario con el email del préstamo' do
      expect(mail.to).to include(loan.email)
    end

    it 'renderiza el remitente desde brand_config' do
      expect(mail.from).to include(brand_config['mail_from'])
    end

    it 'incluye el nombre del suscriptor' do
      expect(mail.body.encoded).to include(loan.first_name)
      expect(mail.body.encoded).to include(loan.last_name)
    end

    it 'incluye el importe suscrito' do
      expect(mail.body.encoded).to include("#{loan.amount}€")
    end

    it 'incluye información sobre plazo de ingreso' do
      expect(mail.body.encoded).to match(/48 horas/)
    end

    it 'adjunta un PDF con información de transferencia' do
      expect(mail.attachments.size).to eq(1)
      expect(mail.attachments.first.filename).to match(/IngresoMicrocreditos/)
    end
  end
end
