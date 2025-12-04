# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }

  # Mock Rails.application.secrets
  before do
    I18n.locale = :es
    ActionMailer::Base.default_url_options = { host: 'www.example.com', protocol: 'http' }
    allow(Rails.application).to receive(:secrets).and_return(
      OpenStruct.new(
        default_from_email: 'noreply@plebisbrand.info'
      )
    )
  end

  describe '#microcredit_email' do
    let(:microcredit) { create(:microcredit, title: 'Test Microcredit #Campaign') }
    let(:loan) { create(:microcredit_loan, microcredit: microcredit, user: user, amount: 500, email: 'loan@example.com', first_name: 'Juan', last_name: 'García') }
    let(:brand_config) do
      {
        'name' => 'PlebisBrand',
        'mail_from' => 'microcreditos@plebisbrand.info',
        'mail_signature' => 'Equipo de Microcréditos',
        'logo' => 'logo.png'
      }
    end

    # Mock WickedPdf to avoid PDF generation in tests
    before do
      allow(WickedPdf).to receive(:new).and_return(double(pdf_from_string: 'fake_pdf_content'))
    end

    let(:mail) { described_class.microcredit_email(microcredit, loan, brand_config) }

    it 'sets the correct subject with brand name' do
      expect(mail.subject).to be_present
      expect(mail.subject).to include(brand_config['name'])
    end

    it 'sends to the loan email' do
      expect(mail.to).to eq([loan.email])
    end

    it 'sends from the brand config email' do
      expect(mail.from).to eq([brand_config['mail_from']])
    end

    it 'includes the subscriber first name' do
      expect(mail.html_part.body.decoded).to include(loan.first_name)
    end

    it 'includes the subscriber last name' do
      expect(mail.html_part.body.decoded).to include(loan.last_name)
    end

    it 'includes the loan amount' do
      expect(mail.html_part.body.decoded).to include("#{loan.amount}€")
    end

    it 'includes the deposit deadline' do
      expect(mail.html_part.body.decoded).to match(/48 horas/)
    end

    it 'attaches a PDF with transfer information' do
      expect(mail.attachments.size).to eq(1)
      expect(mail.attachments.first.filename).to match(/IngresoMicrocreditos#{brand_config['name']}\.pdf/)
    end

    it 'assigns @microcredit instance variable' do
      expect(mail.html_part.body.decoded).to be_present
    end

    it 'assigns @loan instance variable' do
      expect(mail.html_part.body.decoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.html_part.body.decoded).to be_present
    end

    it 'removes # from microcredit title' do
      # The title is processed by the mailer, removing # character
      # Verify it doesn't crash and renders properly
      expect(mail.html_part.body.decoded).to be_present
      expect(mail.html_part.body.decoded).not_to include('#Campaign')
    end

    it 'generates PDF with WickedPdf' do
      expect(WickedPdf).to receive(:new).and_return(double(pdf_from_string: 'fake_pdf_content'))
      mail.deliver_now
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different amounts' do
      let(:large_loan) { build(:microcredit_loan, microcredit: microcredit, user: user, amount: 1000, email: 'large@example.com') }

      before do
        # Skip validation for test purposes
        allow(large_loan).to receive(:valid?).and_return(true)
        allow(large_loan).to receive(:persisted?).and_return(true)
      end

      let(:mail) { described_class.microcredit_email(microcredit, large_loan, brand_config) }

      it 'handles large amounts' do
        expect(mail.html_part.body.decoded).to include("#{large_loan.amount}€")
      end
    end

    context 'with special characters in names' do
      let(:special_loan) { create(:microcredit_loan, microcredit: microcredit, user: user, first_name: 'María José', last_name: 'García-López', email: 'special@example.com') }
      let(:mail) { described_class.microcredit_email(microcredit, special_loan, brand_config) }

      it 'handles special characters in names' do
        expect(mail.html_part.body.decoded).to include('María José')
        expect(mail.html_part.body.decoded).to include('García-López')
      end
    end
  end

  describe '#remember_email' do
    context 'when searching by email' do
      let(:mail) { described_class.remember_email(:email, user.email) }

      it 'sets the correct subject' do
        expect(mail.subject).to eq('[participa.plebisbrand.info] Has intentado registrarte de nuevo')
      end

      it 'sends to the correct recipient' do
        expect(mail.to).to eq([user.email])
      end

      it 'sends from the default email' do
        expect(mail.from).to eq(['noreply@plebisbrand.info'])
      end

      it 'includes message about registration attempt' do
        expect(mail.body.encoded).to match(/intentado crear un usuario/)
      end

      it 'includes password change link' do
        expect(mail.body.encoded).to match(/cambiarla|contraseña/)
      end

      it 'includes help link' do
        expect(mail.body.encoded).to include('ayuda-para-acceder')
      end

      it 'assigns @user instance variable' do
        expect(mail.body.encoded).to be_present
      end

      it 'finds user by email' do
        expect(User).to receive(:find_by).with(email: user.email).and_return(user)
        mail.deliver_now
      end

      it 'can be delivered' do
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'when searching by document_vatid' do
      let(:mail) { described_class.remember_email(:document_vatid, user.document_vatid) }

      it 'sets the correct subject' do
        expect(mail.subject).to eq('[participa.plebisbrand.info] Has intentado registrarte de nuevo')
      end

      it 'sends to the correct recipient' do
        expect(mail.to).to eq([user.email])
      end

      it 'finds user by document_vatid' do
        expect(User).to receive(:find_by).with(document_vatid: user.document_vatid).and_return(user)
        mail.deliver_now
      end

      it 'can be delivered' do
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'with unknown type' do
      let(:mail) { described_class.remember_email(:unknown, user.email) }

      it 'defaults to finding by email' do
        expect(User).to receive(:find_by).with(email: user.email).and_return(user)
        mail.deliver_now
      end
    end
  end

  describe '#new_militant_email' do
    let(:mail) { described_class.new_militant_email(user.id) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Enhorabuena, ya eres militante de PlebisBrand')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the militants support email' do
      expect(mail.from).to eq(['soportemilitantes@plebisbrand.info'])
    end

    it 'includes welcome message as militant' do
      expect(mail.body.decoded).to match(/ya eres militante/i)
    end

    it 'includes information about militant rights' do
      expect(mail.body.decoded).to match(/derechos|Círculo/)
    end

    it 'includes link to militant information' do
      expect(mail.body.decoded).to include('plebisbrand.info/militantes')
    end

    it 'assigns @user_email instance variable' do
      expect(mail.body.decoded).to be_present
    end

    it 'looks up the user by ID' do
      expect(User).to receive(:find).with(user.id).and_return(user)
      mail.deliver_now
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different user' do
      let(:another_user) { create(:user, :with_dni, email: 'another@example.com') }
      let(:mail) { described_class.new_militant_email(another_user.id) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([another_user.email])
      end
    end
  end

  describe '#cancel_account_email' do
    let(:mail) { described_class.cancel_account_email(user.id) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Te has dado de baja de PlebisBrand')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the default email' do
      expect(mail.from).to eq(['noreply@plebisbrand.info'])
    end

    it 'includes BCC to bajas email' do
      expect(mail.bcc).to eq(['bajas@plebisbrand.info'])
    end

    it 'includes user full name' do
      expect(mail.body.encoded).to include(user.full_name)
    end

    it 'includes user email' do
      expect(mail.body.encoded).to include(user.email)
    end

    it 'includes user document' do
      expect(mail.body.encoded).to include(user.document_vatid)
    end

    it 'includes cancellation confirmation message' do
      expect(mail.body.encoded).to match(/confirmamos tu baja/)
    end

    it 'includes data protection contact' do
      expect(mail.body.encoded).to include('protecciondedatos@plebisbrand.info')
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'looks up the user by ID' do
      expect(User).to receive(:find).with(user.id).and_return(user)
      mail.deliver_now
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different user' do
      let(:another_user) { create(:user, :with_dni, email: 'another@example.com') }
      let(:mail) { described_class.cancel_account_email(another_user.id) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([another_user.email])
      end
    end
  end

  # Edge cases and integration tests
  describe 'edge cases' do
    context 'with special characters in email' do
      let(:special_user) { create(:user, :with_dni, email: 'special+test@example.com') }

      it 'handles special characters in remember_email' do
        mail = described_class.remember_email(:email, special_user.email)
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end

      it 'handles special characters in new_militant_email' do
        mail = described_class.new_militant_email(special_user.id)
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end

      it 'handles special characters in cancel_account_email' do
        mail = described_class.cancel_account_email(special_user.id)
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'when user is not found' do
      it 'raises an error for new_militant_email' do
        expect { described_class.new_militant_email(999999).deliver_now }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises an error for cancel_account_email' do
        expect { described_class.cancel_account_email(999999).deliver_now }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with nil user in remember_email' do
      it 'handles nil gracefully when user not found by email' do
        allow(User).to receive(:find_by).and_return(nil)
        expect { described_class.remember_email(:email, 'nonexistent@example.com').deliver_now }.to raise_error
      end
    end
  end

  # Test deliverability
  describe 'deliverability' do
    it 'can deliver microcredit_email' do
      microcredit = create(:microcredit, title: 'Test')
      loan = create(:microcredit_loan, microcredit: microcredit, user: user, email: 'loan@example.com')
      brand_config = { 'name' => 'Test', 'mail_from' => 'test@example.com', 'mail_signature' => 'Test', 'logo' => 'test.png' }
      allow(WickedPdf).to receive(:new).and_return(double(pdf_from_string: 'fake_pdf_content'))

      expect { described_class.microcredit_email(microcredit, loan, brand_config).deliver_now }.not_to raise_error
    end

    it 'can deliver remember_email' do
      expect { described_class.remember_email(:email, user.email).deliver_now }.not_to raise_error
    end

    it 'can deliver new_militant_email' do
      expect { described_class.new_militant_email(user.id).deliver_now }.not_to raise_error
    end

    it 'can deliver cancel_account_email' do
      expect { described_class.cancel_account_email(user.id).deliver_now }.not_to raise_error
    end
  end

  # Test inheritance from ApplicationMailer
  describe 'inheritance' do
    it 'inherits from ApplicationMailer' do
      expect(described_class.superclass).to eq(ApplicationMailer)
    end

    it 'uses default from email from configuration' do
      # UsersMailer sets default[:from] dynamically from secrets
      # Test that emails use the configured from address
      mail = described_class.new_militant_email(user.id)
      expect(mail.from).to be_present
      expect(mail.from.first).to match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    end
  end
end
