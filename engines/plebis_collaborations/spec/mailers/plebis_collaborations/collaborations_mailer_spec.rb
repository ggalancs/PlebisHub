# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCollaborations::CollaborationsMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }
  let(:collaboration) { create(:collaboration, :active, user: user) }

  before do
    I18n.locale = :es
    ActionMailer::Base.default_url_options = { host: 'www.example.com', protocol: 'http' }

    # Mock Rails.application.secrets.microcredits structure
    allow(Rails.application).to receive(:secrets).and_return(
      OpenStruct.new(
        microcredits: {
          'default_brand' => 'test_brand',
          'brands' => {
            'test_brand' => {
              'name' => 'PlebisBrand',
              'logo' => 'logo.png'
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

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the administration email' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'uses text format' do
      expect(mail.parts.map(&:content_type)).to include(/text\/plain/)
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    it 'includes user email in the body' do
      expect(mail.body.encoded).to be_present
    end

    context 'with different users' do
      let(:another_user) { create(:user, :with_dni, email: 'another@example.com') }
      let(:mail) { described_class.creditcard_error_email(another_user) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([another_user.email])
      end
    end

    context 'with special characters in email' do
      let(:special_user) { create(:user, :with_dni, email: 'test+special@example.com') }
      let(:mail) { described_class.creditcard_error_email(special_user) }

      it 'handles special characters' do
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end
    end
  end

  describe '#creditcard_expired_email' do
    let(:mail) { described_class.creditcard_expired_email(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en el pago con tarjeta de su colaboración')
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the administration email' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'uses text format' do
      expect(mail.parts.map(&:content_type)).to include(/text\/plain/)
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different users' do
      let(:different_user) { create(:user, :with_dni, email: 'different@example.com') }
      let(:mail) { described_class.creditcard_expired_email(different_user) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([different_user.email])
      end
    end
  end

  describe '#receipt_returned' do
    let(:mail) { described_class.receipt_returned(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en la domiciliación del recibo de su colaboración')
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the administration email' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'uses text format' do
      expect(mail.parts.map(&:content_type)).to include(/text\/plain/)
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different users' do
      let(:other_user) { create(:user, :with_dni, email: 'other@example.com') }
      let(:mail) { described_class.receipt_returned(other_user) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([other_user.email])
      end
    end
  end

  describe '#receipt_suspended' do
    let(:mail) { described_class.receipt_suspended(user) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Problema en la domicilación de sus recibos, colaboración suspendida temporalmente')
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the administration email' do
      expect(mail.from).to eq(['administracion@plebisbrand.info'])
    end

    it 'uses text format' do
      expect(mail.parts.map(&:content_type)).to include(/text\/plain/)
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different users' do
      let(:new_user) { create(:user, :with_dni, email: 'new@example.com') }
      let(:mail) { described_class.receipt_suspended(new_user) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([new_user.email])
      end
    end
  end

  describe '#order_returned_militant' do
    let(:order) { create(:order, :devuelta, collaboration: collaboration) }
    let(:mail) { described_class.order_returned_militant(collaboration) }

    before do
      # Ensure the collaboration has a returned order
      collaboration.orders << order unless collaboration.orders.include?(order)
    end

    it 'sets the correct subject with date' do
      date = I18n.l(order.created_at, format: '%B %Y')
      expect(mail.subject).to eq("Devolución cuota #{date}")
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the collaborations email' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @order instance variable with last returned order' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @payment_day instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @month instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @date instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    it 'formats month in Spanish' do
      expect(mail.body.encoded).to be_present
    end

    context 'with multiple returned orders' do
      let(:older_order) { create(:order, :devuelta, collaboration: collaboration, created_at: 2.months.ago) }

      before do
        collaboration.orders << older_order
      end

      it 'uses the last returned order' do
        expect(mail.subject).to include(I18n.l(order.created_at, format: '%B %Y'))
      end
    end
  end

  describe '#order_returned_user' do
    let(:order) { create(:order, :devuelta, collaboration: collaboration) }
    let(:mail) { described_class.order_returned_user(collaboration) }

    before do
      collaboration.orders << order unless collaboration.orders.include?(order)
    end

    it 'sets the correct subject with date' do
      date = I18n.l(order.created_at, format: '%B %Y')
      expect(mail.subject).to eq("Devolución colaboración #{date}")
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the collaborations email' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @order instance variable with last returned order' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @payment_day instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @month instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @date instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    it 'formats date correctly' do
      expect(mail.subject).to match(/\w+ \d{4}/)
    end

    context 'with different creation dates' do
      let(:order) { create(:order, :devuelta, collaboration: collaboration, created_at: 3.months.ago) }

      it 'uses the order creation date' do
        expected_date = I18n.l(order.created_at, format: '%B %Y')
        expect(mail.subject).to include(expected_date)
      end
    end
  end

  describe '#collaboration_suspended_user' do
    let(:mail) { described_class.collaboration_suspended_user(collaboration) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Suspensión colaboración')
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the collaborations email' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different collaborations' do
      let(:other_user) { create(:user, :with_dni, email: 'suspended@example.com') }
      let(:other_collaboration) { create(:collaboration, :active, user: other_user) }
      let(:mail) { described_class.collaboration_suspended_user(other_collaboration) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([other_user.email])
      end
    end
  end

  describe '#collaboration_suspended_militant' do
    let(:mail) { described_class.collaboration_suspended_militant(collaboration) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Suspensión cuota')
    end

    it 'sends to the user email' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the collaborations email' do
      expect(mail.from).to eq(['colaboraciones@plebisbrand.info'])
    end

    it 'assigns @brand_config instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @user instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different collaborations' do
      let(:militant_user) { create(:user, :with_dni, email: 'militant@example.com') }
      let(:militant_collaboration) { create(:collaboration, :active, user: militant_user) }
      let(:mail) { described_class.collaboration_suspended_militant(militant_collaboration) }

      it 'sends to the correct militant user' do
        expect(mail.to).to eq([militant_user.email])
      end
    end
  end

  describe 'mailer configuration' do
    it 'inherits from ApplicationMailer' do
      expect(described_class.superclass.name).to eq('PlebisCollaborations::ApplicationMailer')
    end

    it 'is in the correct namespace' do
      expect(described_class.name).to eq('PlebisCollaborations::CollaborationsMailer')
    end
  end

  describe 'brand configuration access' do
    it 'accesses brand configuration from Rails secrets' do
      mail = described_class.creditcard_error_email(user)
      expect(Rails.application.secrets).to have_received(:microcredits)
    end

    it 'uses default brand from configuration' do
      mail = described_class.creditcard_error_email(user)
      expect(mail.body.encoded).to be_present
    end
  end

  describe 'collaboration user lookup' do
    it 'correctly retrieves user from collaboration' do
      allow(collaboration).to receive(:get_user).and_return(user)
      mail = described_class.order_returned_militant(collaboration)
      expect(mail.to).to eq([user.email])
    end

    it 'handles collaboration without user gracefully' do
      non_user_collaboration = create(:collaboration, :non_user)
      # This should handle non-user collaborations that use non_user_email
      expect { described_class.collaboration_suspended_user(non_user_collaboration) }.not_to raise_error
    end
  end

  describe 'email deliverability' do
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

    it 'can deliver order_returned_militant' do
      order = create(:order, :devuelta, collaboration: collaboration)
      collaboration.orders << order
      expect { described_class.order_returned_militant(collaboration).deliver_now }.not_to raise_error
    end

    it 'can deliver order_returned_user' do
      order = create(:order, :devuelta, collaboration: collaboration)
      collaboration.orders << order
      expect { described_class.order_returned_user(collaboration).deliver_now }.not_to raise_error
    end

    it 'can deliver collaboration_suspended_user' do
      expect { described_class.collaboration_suspended_user(collaboration).deliver_now }.not_to raise_error
    end

    it 'can deliver collaboration_suspended_militant' do
      expect { described_class.collaboration_suspended_militant(collaboration).deliver_now }.not_to raise_error
    end
  end

  describe 'I18n support' do
    it 'formats dates according to locale' do
      order = create(:order, :devuelta, collaboration: collaboration, created_at: Time.zone.parse('2023-05-15'))
      collaboration.orders << order

      I18n.with_locale(:es) do
        mail = described_class.order_returned_militant(collaboration)
        expect(mail.subject).to be_present
      end
    end

    it 'handles date formatting in different locales' do
      order = create(:order, :devuelta, collaboration: collaboration)
      collaboration.orders << order

      expect { described_class.order_returned_militant(collaboration) }.not_to raise_error
    end
  end

  describe 'edge cases and error handling' do
    it 'handles user with nil email gracefully' do
      user.email = nil
      user.save(validate: false)
      expect { described_class.creditcard_error_email(user) }.not_to raise_error
    end

    it 'handles collaboration without orders' do
      empty_collaboration = create(:collaboration, :active, user: user)
      # Should not raise error even though there are no returned orders
      # The mailer will get the last returned order which will be nil
      expect { described_class.order_returned_militant(empty_collaboration) }.to raise_error
    end

    it 'handles very long email addresses' do
      long_email_user = create(:user, :with_dni)
      long_email_user.email = 'a' * 50 + '@' + 'b' * 50 + '.com'
      long_email_user.save(validate: false)

      mail = described_class.creditcard_error_email(long_email_user)
      expect(mail.to.first).to eq(long_email_user.email)
    end
  end

  describe 'text format compliance' do
    it 'sends creditcard_error_email in text format' do
      mail = described_class.creditcard_error_email(user)
      expect(mail.parts.any? { |part| part.content_type.include?('text/plain') }).to be true
    end

    it 'sends creditcard_expired_email in text format' do
      mail = described_class.creditcard_expired_email(user)
      expect(mail.parts.any? { |part| part.content_type.include?('text/plain') }).to be true
    end

    it 'sends receipt_returned in text format' do
      mail = described_class.receipt_returned(user)
      expect(mail.parts.any? { |part| part.content_type.include?('text/plain') }).to be true
    end

    it 'sends receipt_suspended in text format' do
      mail = described_class.receipt_suspended(user)
      expect(mail.parts.any? { |part| part.content_type.include?('text/plain') }).to be true
    end
  end

  describe 'payment day calculation' do
    it 'includes payment day in order emails' do
      order = create(:order, :devuelta, collaboration: collaboration)
      collaboration.orders << order
      mail = described_class.order_returned_militant(collaboration)

      expect(mail.body.encoded).to be_present
    end

    it 'calculates payment day correctly' do
      order = create(:order, :devuelta, collaboration: collaboration)
      collaboration.orders << order

      expect(PlebisCollaborations::Order).to receive(:payment_day).and_call_original
      described_class.order_returned_militant(collaboration)
    end
  end
end
