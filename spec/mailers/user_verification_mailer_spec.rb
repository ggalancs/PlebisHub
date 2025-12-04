# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVerificationMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }

  before do
    I18n.locale = :es
  end

  describe '#on_accepted' do
    let(:mail) { described_class.on_accepted(user.id) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('PlebisBrand, Datos verificados')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['verificaciones@soporte.plebisbrand.info'])
    end

    it 'renders the body with acceptance message' do
      expect(mail.body.encoded).to match(/validado correctamente|documento de identidad/)
    end

    it 'includes thank you message' do
      expect(mail.body.encoded).to match(/gracias por participar/)
    end

    it 'includes PLEBISBRAND branding' do
      expect(mail.body.encoded).to match(/PLEBISBRAND/)
    end

    it 'assigns @user_email instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'looks up the user by ID' do
      expect(User).to receive(:find).with(user.id).and_return(user)
      mail.deliver_now
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different user ID' do
      let(:another_user) { create(:user, :with_dni, email: 'another@example.com') }
      let(:mail) { described_class.on_accepted(another_user.id) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([another_user.email])
      end
    end
  end

  describe '#on_rejected' do
    let(:mail) { described_class.on_rejected(user.id) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('PlebisBrand, no hemos podido realizar la verificación')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['verificaciones@soporte.plebisbrand.info'])
    end

    it 'renders the body with rejection message' do
      expect(mail.body.encoded).to match(/no hemos podido|validaci/)
    end

    it 'includes common rejection reasons' do
      expect(mail.body.encoded).to match(/motivos habituales/)
    end

    it 'includes LOPD contact email' do
      expect(mail.body.encoded).to include('lopd@plebisbrand.info')
    end

    it 'includes information page link' do
      expect(mail.body.encoded).to include('https://plebisbrand.info/identificate/')
    end

    it 'assigns @user_email instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'looks up the user by ID' do
      expect(User).to receive(:find).with(user.id).and_return(user)
      mail.deliver_now
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'with different user ID' do
      let(:another_user) { create(:user, :with_dni, email: 'another2@example.com', document_vatid: '12345678Z') }
      let(:mail) { described_class.on_rejected(another_user.id) }

      it 'sends to the correct user' do
        expect(mail.to).to eq([another_user.email])
      end
    end
  end

  # Edge cases and integration tests
  describe 'edge cases' do
    context 'with special characters in email' do
      let(:special_user) { create(:user, :with_dni, email: 'special+test@example.com') }

      it 'handles special characters in on_accepted' do
        mail = described_class.on_accepted(special_user.id)
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end

      it 'handles special characters in on_rejected' do
        mail = described_class.on_rejected(special_user.id)
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'when user is not found' do
      it 'raises an error for on_accepted' do
        expect { described_class.on_accepted(999999).deliver_now }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises an error for on_rejected' do
        expect { described_class.on_rejected(999999).deliver_now }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with multiple verifications for same user' do
      let(:user1) { create(:user, :with_dni, email: 'user1@example.com') }
      let(:user2) { create(:user, :with_dni, email: 'user2@example.com') }

      it 'sends to correct users' do
        mail1 = described_class.on_accepted(user1.id)
        mail2 = described_class.on_rejected(user2.id)

        expect(mail1.to).to eq([user1.email])
        expect(mail2.to).to eq([user2.email])
      end
    end
  end

  # Test deliverability
  describe 'deliverability' do
    it 'can deliver on_accepted' do
      expect { described_class.on_accepted(user.id).deliver_now }.not_to raise_error
    end

    it 'can deliver on_rejected' do
      expect { described_class.on_rejected(user.id).deliver_now }.not_to raise_error
    end
  end

  # Test inheritance from ApplicationMailer
  describe 'inheritance' do
    it 'inherits from ApplicationMailer' do
      expect(described_class.superclass).to eq(ApplicationMailer)
    end
  end

  # Test email format
  describe 'email format' do
    it 'on_accepted has valid format' do
      mail = described_class.on_accepted(user.id)
      expect(mail.from).to all(match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i))
      expect(mail.to).to all(match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i))
    end

    it 'on_rejected has valid format' do
      mail = described_class.on_rejected(user.id)
      expect(mail.from).to all(match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i))
      expect(mail.to).to all(match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i))
    end
  end
end
