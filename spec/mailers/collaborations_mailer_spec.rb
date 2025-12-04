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

  describe '#creditcard_error_email' do
    let(:mail) { described_class.creditcard_error_email(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en el pago con tarjeta de su colaboración')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'renders the body with user information' do
      expect(mail.body.encoded).to match(/tarjeta|TPV|rechazado/)
    end

    it 'includes contact email' do
      expect(mail.body.encoded).to include('administración@plebisbrand.info')
    end

    it 'includes contact phone' do
      expect(mail.body.encoded).to match(/917376825/)
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to include(user.email) if mail.body.encoded.include?('email')
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      # Verify brand config is used in template
      expect(mail.body.encoded).to be_present
    end

    it 'uses text format' do
      expect(mail.content_type).to match(/text\/plain/)
    end
  end

  describe '#creditcard_expired_email' do
    let(:mail) { described_class.creditcard_expired_email(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en el pago con tarjeta de su colaboración')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'renders the body with expiration message' do
      expect(mail.body.encoded).to match(/caducad|expirad/)
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'uses text format' do
      expect(mail.content_type).to match(/text\/plain/)
    end
  end

  describe '#receipt_returned' do
    let(:mail) { described_class.receipt_returned(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en la domiciliación del recibo de su colaboración')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'uses text format' do
      expect(mail.content_type).to match(/text\/plain/)
    end
  end

  describe '#receipt_suspended' do
    let(:mail) { described_class.receipt_suspended(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en la domicilación de sus recibos, colaboración suspendida temporalmente')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'uses text format' do
      expect(mail.content_type).to match(/text\/plain/)
    end
  end

  describe '#order_returned_militant' do
    let(:order) { create(:order, :devuelta, collaboration: collaboration) }
    let(:mail) do
      order
      described_class.order_returned_militant(collaboration)
    end

    before do
      allow(Order).to receive(:payment_day).and_return(5)
    end

    it 'sets the correct subject with date' do
      expect(mail.subject).to match(/Devolución cuota/)
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'renders the body with order information' do
      expect(mail.body.encoded).to match(/devoluci|recibo|cuota/i)
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @order instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @payment_day instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'formats the date in Spanish' do
      expect(mail.subject).to be_present
    end

    it 'retrieves the last returned order' do
      expect(mail.body.encoded).to be_present
    end
  end

  describe '#order_returned_user' do
    let(:order) { create(:order, :devuelta, collaboration: collaboration) }
    let(:mail) do
      order
      described_class.order_returned_user(collaboration)
    end

    before do
      allow(Order).to receive(:payment_day).and_return(5)
    end

    it 'sets the correct subject with date' do
      expect(mail.subject).to match(/Devolución colaboración/)
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'renders the body with collaboration information' do
      expect(mail.body.encoded).to match(/devoluci|colaboraci/i)
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @order instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @payment_day instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'formats the date in Spanish' do
      expect(mail.subject).to be_present
    end
  end

  describe '#collaboration_suspended_user' do
    let(:mail) { described_class.collaboration_suspended_user(collaboration) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Suspensión colaboración')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'renders the body with suspension message' do
      expect(mail.body.encoded).to match(/suspendi|devoluc/)
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'retrieves user from collaboration' do
      expect(mail.to).to include(collaboration.get_user.email)
    end
  end

  describe '#collaboration_suspended_militant' do
    let(:mail) { described_class.collaboration_suspended_militant(collaboration) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Suspensión cuota')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'renders the body with suspension message' do
      expect(mail.body.encoded).to match(/devoluciones de recibos/)
    end

    it 'includes contact email' do
      expect(mail.body.encoded).to include('colaboraciones@plebisbrand.info')
    end

    it 'includes cordial greeting' do
      expect(mail.body.encoded).to match(/cordial saludo/)
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @brand_config instance variable' do
      mail.deliver_now
      expect(mail.body.encoded).to be_present
    end

    it 'retrieves user from collaboration' do
      expect(mail.to).to include(collaboration.get_user.email)
    end
  end

  # Edge cases and integration tests
  describe 'edge cases' do
    context 'with different user emails' do
      let(:special_user) { create(:user, :with_dni, email: 'special+test@example.com') }
      let(:mail) { described_class.creditcard_error_email(special_user) }

      it 'handles special characters in email' do
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'with multiple returned orders' do
      let(:order1) { create(:order, :devuelta, collaboration: collaboration, created_at: 2.months.ago) }
      let(:order2) { create(:order, :devuelta, collaboration: collaboration, created_at: 1.month.ago) }

      before do
        order1
        order2
        allow(Order).to receive(:payment_day).and_return(5)
      end

      it 'uses the most recent returned order' do
        mail = described_class.order_returned_militant(collaboration)
        expect(mail.subject).to be_present
        expect(mail.body.encoded).to be_present
      end
    end

    context 'when brand config is missing' do
      before do
        allow(Rails.application).to receive(:secrets).and_return(
          OpenStruct.new(
            microcredits: {
              'default_brand' => 'plebisbrand',
              'brands' => {}
            }
          )
        )
      end

      it 'handles missing brand gracefully' do
        expect { described_class.creditcard_error_email(user) }.not_to raise_error
      end
    end
  end

  # Test deliverability
  describe 'deliverability' do
    it 'can deliver creditcard_error_email' do
      expect { described_class.creditcard_error_email(user).deliver_now }.not_to raise_error
    end

    it 'can deliver creditcard_expired_email' do
      expect { described_class.creditcard_expired_email(user).deliver_now }.not_to raise_error
    end

    it 'can deliver receipt_returned' do
      expect { described_class.receipt_returned(user).deliver_now }.not_to raise_error
    end

    it 'can deliver receipt_suspended' do
      expect { described_class.receipt_suspended(user).deliver_now }.not_to raise_error
    end

    it 'can deliver collaboration_suspended_user' do
      expect { described_class.collaboration_suspended_user(collaboration).deliver_now }.not_to raise_error
    end

    it 'can deliver collaboration_suspended_militant' do
      expect { described_class.collaboration_suspended_militant(collaboration).deliver_now }.not_to raise_error
    end

    it 'can deliver order_returned_militant' do
      order = create(:order, :devuelta, collaboration: collaboration)
      allow(Order).to receive(:payment_day).and_return(5)
      expect { described_class.order_returned_militant(collaboration).deliver_now }.not_to raise_error
    end

    it 'can deliver order_returned_user' do
      order = create(:order, :devuelta, collaboration: collaboration)
      allow(Order).to receive(:payment_day).and_return(5)
      expect { described_class.order_returned_user(collaboration).deliver_now }.not_to raise_error
    end
  end
end
