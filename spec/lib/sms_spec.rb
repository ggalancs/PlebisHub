# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/sms'

RSpec.describe SMS::Sender do
  describe '.send_message' do
    let(:phone_number) { '+34600123456' }
    let(:activation_code) { '123456' }

    context 'in staging environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'sends SMS via Esendex in staging' do
        esendex_account = instance_double('Esendex::Account')
        allow(Esendex::Account).to receive(:new).and_return(esendex_account)
        expect(esendex_account).to receive(:send_message).with(
          to: phone_number,
          body: "Tu código de activación es #{activation_code}"
        )

        described_class.send_message(phone_number, activation_code)
      end

      it 'formats the message correctly' do
        esendex_account = instance_double('Esendex::Account')
        allow(Esendex::Account).to receive(:new).and_return(esendex_account)
        expect(esendex_account).to receive(:send_message).with(
          hash_including(body: 'Tu código de activación es 999888')
        )

        described_class.send_message(phone_number, '999888')
      end
    end

    context 'in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'sends SMS via Esendex in production' do
        esendex_account = instance_double('Esendex::Account')
        allow(Esendex::Account).to receive(:new).and_return(esendex_account)
        expect(esendex_account).to receive(:send_message).with(
          to: phone_number,
          body: "Tu código de activación es #{activation_code}"
        )

        described_class.send_message(phone_number, activation_code)
      end

      it 'handles different phone number formats' do
        esendex_account = instance_double('Esendex::Account')
        allow(Esendex::Account).to receive(:new).and_return(esendex_account)
        expect(esendex_account).to receive(:send_message).with(
          hash_including(to: '0034600123456')
        )

        described_class.send_message('0034600123456', activation_code)
      end
    end

    context 'in development environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      end

      it 'logs the activation code instead of sending SMS' do
        allow(Rails.logger).to receive(:info).and_call_original
        described_class.send_message(phone_number, activation_code)
        expect(Rails.logger).to have_received(:info).with(
          "ACTIVATION CODE para #{phone_number} == #{activation_code}"
        ).at_least(:once)
      end

      it 'does not call Esendex in development' do
        allow(Rails.logger).to receive(:info)
        expect(Esendex::Account).not_to receive(:new)

        described_class.send_message(phone_number, activation_code)
      end

      it 'logs with different phone numbers' do
        allow(Rails.logger).to receive(:info).and_call_original
        described_class.send_message('+34611222333', '789012')
        expect(Rails.logger).to have_received(:info).with(
          'ACTIVATION CODE para +34611222333 == 789012'
        ).at_least(:once)
      end
    end

    context 'in test environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      end

      it 'logs the activation code instead of sending SMS' do
        allow(Rails.logger).to receive(:info).and_call_original
        described_class.send_message(phone_number, activation_code)
        expect(Rails.logger).to have_received(:info).with(
          "ACTIVATION CODE para #{phone_number} == #{activation_code}"
        ).at_least(:once)
      end

      it 'does not call Esendex in test' do
        allow(Rails.logger).to receive(:info)
        expect(Esendex::Account).not_to receive(:new)

        described_class.send_message(phone_number, activation_code)
      end
    end

    context 'with different activation codes' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
        allow(Rails.logger).to receive(:info).and_call_original
      end

      it 'handles numeric codes' do
        described_class.send_message(phone_number, '123456')
        expect(Rails.logger).to have_received(:info).with(
          "ACTIVATION CODE para #{phone_number} == 123456"
        ).at_least(:once)
      end

      it 'handles alphanumeric codes' do
        described_class.send_message(phone_number, 'ABC123')
        expect(Rails.logger).to have_received(:info).with(
          "ACTIVATION CODE para #{phone_number} == ABC123"
        ).at_least(:once)
      end

      it 'handles empty codes' do
        described_class.send_message(phone_number, '')
        expect(Rails.logger).to have_received(:info).with(
          "ACTIVATION CODE para #{phone_number} == "
        ).at_least(:once)
      end
    end

    context 'with different phone number formats' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
        allow(Rails.logger).to receive(:info).and_call_original
      end

      it 'handles international format' do
        described_class.send_message('+34600123456', '123456')
        expect(Rails.logger).to have_received(:info).with(
          'ACTIVATION CODE para +34600123456 == 123456'
        ).at_least(:once)
      end

      it 'handles national format' do
        described_class.send_message('600123456', '123456')
        expect(Rails.logger).to have_received(:info).with(
          'ACTIVATION CODE para 600123456 == 123456'
        ).at_least(:once)
      end

      it 'handles format with spaces' do
        described_class.send_message('+34 600 123 456', '123456')
        expect(Rails.logger).to have_received(:info).with(
          'ACTIVATION CODE para +34 600 123 456 == 123456'
        ).at_least(:once)
      end
    end

    context 'with unknown environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('custom'))
      end

      it 'logs the activation code for unknown environments' do
        allow(Rails.logger).to receive(:info).and_call_original
        described_class.send_message(phone_number, activation_code)
        expect(Rails.logger).to have_received(:info).with(
          "ACTIVATION CODE para #{phone_number} == #{activation_code}"
        ).at_least(:once)
      end

      it 'does not call Esendex for unknown environments' do
        allow(Rails.logger).to receive(:info)
        expect(Esendex::Account).not_to receive(:new)

        described_class.send_message(phone_number, activation_code)
      end
    end
  end
end
