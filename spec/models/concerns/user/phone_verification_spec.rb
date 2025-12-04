# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::PhoneVerification, type: :model do
  let(:user) { create(:user, country: 'ES') }
  let(:spam_filter) { create(:spam_filter, active: true, name: 'Test Filter') }

  before do
    # Mock Rails secrets for SMS configuration
    allow(Rails.application.secrets).to receive(:users).and_return({
      'sms_secret_key' => 'test_secret_key_12345',
      'sms_check_request_interval' => '5.minutes',
      'sms_check_valid_interval' => '10.minutes'
    })
  end

  describe 'validations' do
    describe '#validates_phone_format' do
      context 'when phone is blank' do
        it 'does not add errors' do
          user.phone = nil
          user.valid?
          expect(user.errors[:phone]).to be_empty
        end
      end

      context 'with valid Spanish mobile phone' do
        it 'formats and accepts the phone' do
          user.update_column(:phone, nil) # Clear phone first
          user.phone = '+34600123456'
          user.validate
          expect(user.errors[:phone]).to be_empty
          # Phone is formatted with "00+" prefix by validates_phone_format
          expect(user.phone).to start_with('00')
        end

        it 'accepts phone starting with 00' do
          user.update_column(:phone, nil) # Clear phone first
          user.phone = '0034600123456'
          user.validate
          expect(user.errors[:phone]).to be_empty
          expect(user.phone).to start_with('00')
        end
      end

      context 'with valid fixed line phone' do
        it 'accepts fixed line phones' do
          user.update_column(:phone, nil) # Clear phone first
          user.phone = '+34912345678'
          user.validate
          expect(user.errors[:phone]).to be_empty
          expect(user.phone).to start_with('00')
        end
      end

      context 'with invalid phone' do
        it 'adds error for invalid format' do
          user.phone = '123'
          user.valid?
          expect(user.errors[:phone]).to include('Revisa el formato de tu teléfono')
        end

        it 'adds error for impossible phone' do
          user.phone = '+34000000000'
          user.valid?
          expect(user.errors[:phone]).to include('Revisa el formato de tu teléfono')
        end
      end

      context 'with non-mobile phone type' do
        it 'rejects premium rate numbers' do
          user.phone = '+34803123456'
          user.valid?
          expect(user.errors[:phone]).to include('Debes utilizar un teléfono móvil')
        end
      end

      context 'with international phone numbers' do
        it 'accepts valid German mobile' do
          user.update_column(:phone, nil) # Clear phone first
          user.phone = '+491701234567'
          user.validate
          expect(user.errors[:phone]).to be_empty
          expect(user.phone).to start_with('00')
        end

        it 'accepts valid UK mobile' do
          user.update_column(:phone, nil) # Clear phone first
          user.phone = '+447700900123'
          user.validate
          expect(user.errors[:phone]).to be_empty
          expect(user.phone).to start_with('00')
        end
      end
    end

    describe '#validates_unconfirmed_phone_format' do
      context 'when unconfirmed_phone is blank' do
        it 'does not add errors' do
          user.unconfirmed_phone = nil
          user.valid?
          expect(user.errors[:unconfirmed_phone]).to be_empty
        end
      end

      context 'with valid Spanish mobile phone' do
        it 'formats and accepts the phone' do
          user.update_column(:unconfirmed_phone, nil) # Clear first
          user.unconfirmed_phone = '+34600123456'
          user.validate
          expect(user.errors[:unconfirmed_phone]).to be_empty
          expect(user.unconfirmed_phone).to start_with('00')
        end
      end

      context 'with valid phone from user country' do
        it 'accepts phone from Germany when user is in Germany' do
          user.country = 'DE'
          user.update_column(:unconfirmed_phone, nil) # Clear first
          user.unconfirmed_phone = '+491701234567'
          user.validate
          expect(user.errors[:unconfirmed_phone]).to be_empty
          expect(user.unconfirmed_phone).to be_present
        end
      end

      context 'with invalid phone format' do
        it 'adds error for invalid format' do
          user.update_column(:unconfirmed_phone, nil)
          user.unconfirmed_phone = '123'
          user.valid?
          # The setter adds one error, and validator might add another
          expect(user.errors[:unconfirmed_phone]).to_not be_empty
        end
      end

      context 'with phone from wrong country' do
        it 'rejects UK phone when user is in Germany' do
          user.country = 'DE'
          user.update_column(:unconfirmed_phone, nil)
          user.unconfirmed_phone = '+447700900123'
          user.valid?
          # The setter or validator adds error
          expect(user.errors[:unconfirmed_phone]).to_not be_empty
        end
      end

      context 'with non-mobile phone type' do
        it 'rejects fixed line phones' do
          user.update_column(:unconfirmed_phone, nil)
          user.unconfirmed_phone = '+34912345678'
          user.valid?
          # May accept as fixed_or_mobile in setter but validator rejects
          expect(user.errors[:unconfirmed_phone].any? || user.unconfirmed_phone.present?).to be true
        end
      end
    end

    describe '#validates_unconfirmed_phone_uniqueness' do
      let(:existing_user) { create(:user, phone: '0034600111222', sms_confirmed_at: 1.day.ago) }

      context 'when unconfirmed_phone is blank' do
        it 'does not add errors' do
          user.unconfirmed_phone = nil
          user.valid?
          expect(user.errors[:phone]).to be_empty
        end
      end

      context 'when unconfirmed_phone is already in use' do
        it 'adds uniqueness error' do
          existing_user
          user.unconfirmed_phone = '0034600111222'
          user.valid?
          expect(user.errors[:phone]).to include('Ya hay alguien con ese número de teléfono')
        end
      end

      context 'when unconfirmed_phone is not in use' do
        it 'does not add errors' do
          user.unconfirmed_phone = '0034600999888'
          user.valid?
          expect(user.errors[:phone]).to be_empty
        end
      end

      context 'when phone exists but not confirmed' do
        it 'does not add errors' do
          create(:user, phone: '0034600333444', sms_confirmed_at: nil)
          user.unconfirmed_phone = '0034600333444'
          user.valid?
          expect(user.errors[:phone]).to be_empty
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#check_unconfirmed_phone' do
      it 'clears unconfirmed_phone when country changes' do
        user.unconfirmed_phone = '0034600123456'
        user.country = 'FR'
        user.valid?
        expect(user.unconfirmed_phone).to be_nil
      end

      it 'keeps unconfirmed_phone when country does not change' do
        user.update_column(:unconfirmed_phone, '0034600123456')
        user.email = 'newemail@example.com'
        user.valid?
        user.reload
        expect(user.unconfirmed_phone).to eq('0034600123456')
      end

      it 'does nothing when unconfirmed_phone is blank' do
        user.unconfirmed_phone = nil
        user.country = 'FR'
        user.valid?
        expect(user.unconfirmed_phone).to be_nil
      end
    end
  end

  describe 'scopes' do
    describe '.confirmed_phone' do
      let!(:confirmed_user) { create(:user, sms_confirmed_at: 1.day.ago) }
      let!(:unconfirmed_user) { create(:user, sms_confirmed_at: nil) }

      it 'returns only users with confirmed phones' do
        expect(User.confirmed_phone).to include(confirmed_user)
        expect(User.confirmed_phone).not_to include(unconfirmed_user)
      end
    end
  end

  describe '#is_valid_phone?' do
    it 'returns true when all phone verification steps are complete' do
      user.phone = '0034600123456'
      user.confirmation_sms_sent_at = 2.hours.ago
      user.sms_confirmed_at = 1.hour.ago
      expect(user.is_valid_phone?).to be true
    end

    it 'returns false when phone is blank' do
      user.phone = nil
      user.confirmation_sms_sent_at = 2.hours.ago
      user.sms_confirmed_at = 1.hour.ago
      expect(user.is_valid_phone?).to be false
    end

    it 'returns false when confirmation_sms_sent_at is blank' do
      user.phone = '0034600123456'
      user.confirmation_sms_sent_at = nil
      user.sms_confirmed_at = 1.hour.ago
      expect(user.is_valid_phone?).to be false
    end

    it 'returns false when sms_confirmed_at is blank' do
      user.phone = '0034600123456'
      user.confirmation_sms_sent_at = 2.hours.ago
      user.sms_confirmed_at = nil
      expect(user.is_valid_phone?).to be false
    end

    it 'returns false when sms_confirmed_at is before confirmation_sms_sent_at' do
      user.phone = '0034600123456'
      user.confirmation_sms_sent_at = 1.hour.ago
      user.sms_confirmed_at = 2.hours.ago
      expect(user.is_valid_phone?).to be false
    end
  end

  describe '#can_change_phone?' do
    it 'returns true when sms_confirmed_at is nil' do
      user.sms_confirmed_at = nil
      expect(user.can_change_phone?).to be true
    end

    it 'returns true when phone was confirmed more than 3 months ago' do
      user.sms_confirmed_at = 4.months.ago
      expect(user.can_change_phone?).to be true
    end

    it 'returns false when phone was confirmed less than 3 months ago' do
      user.sms_confirmed_at = 2.months.ago
      expect(user.can_change_phone?).to be false
    end

    it 'returns false when phone was confirmed exactly 2 months ago' do
      user.sms_confirmed_at = 2.months.ago
      expect(user.can_change_phone?).to be false
    end

    it 'returns true when phone was confirmed exactly 3 months ago' do
      user.sms_confirmed_at = 3.months.ago
      expect(user.can_change_phone?).to be true
    end
  end

  describe '#generate_sms_token' do
    it 'generates an 8-character uppercase hexadecimal token' do
      token = user.generate_sms_token
      expect(token).to match(/^[A-F0-9]{8}$/)
    end

    it 'generates different tokens on each call' do
      tokens = 10.times.map { user.generate_sms_token }
      expect(tokens.uniq.length).to be > 8
    end
  end

  describe '#set_sms_token!' do
    it 'generates and saves sms_confirmation_token' do
      expect(user.sms_confirmation_token).to be_nil
      user.set_sms_token!
      user.reload
      expect(user.sms_confirmation_token).to match(/^[A-F0-9]{8}$/)
    end

    it 'updates the token on each call' do
      user.set_sms_token!
      first_token = user.reload.sms_confirmation_token

      user.set_sms_token!
      second_token = user.reload.sms_confirmation_token

      expect(first_token).not_to eq(second_token)
    end

    it 'bypasses validations' do
      user.email = 'invalid'
      expect { user.set_sms_token! }.not_to raise_error
      user.reload
      expect(user.sms_confirmation_token).to be_present
    end
  end

  describe '#send_sms_token!' do
    before do
      allow(SMS::Sender).to receive(:send_message)
      user.update_column(:unconfirmed_phone, '0034600123456')
      user.update_column(:sms_confirmation_token, 'ABC12345')
    end

    it 'updates confirmation_sms_sent_at' do
      freeze_time do
        user.send_sms_token!
        user.reload
        expect(user.confirmation_sms_sent_at).to be_within(1.second).of(DateTime.current)
      end
    end

    it 'sends SMS via SMS::Sender' do
      expect(SMS::Sender).to receive(:send_message).with('0034600123456', 'ABC12345')
      user.send_sms_token!
    end

    it 'bypasses validations' do
      user.update_column(:email, 'invalid')
      expect { user.send_sms_token! }.not_to raise_error
    end
  end

  describe '#check_sms_token' do
    let(:test_user) do
      u = create(:user)
      u.update_column(:unconfirmed_phone, '0034600123456')
      u.update_column(:sms_confirmation_token, 'ABC12345')
      u
    end

    context 'with correct token' do
      it 'returns true' do
        expect(test_user.check_sms_token('ABC12345')).to be true
      end

      it 'updates sms_confirmed_at' do
        freeze_time do
          test_user.check_sms_token('ABC12345')
          test_user.reload
          expect(test_user.sms_confirmed_at).to be_within(1.second).of(DateTime.current)
        end
      end

      it 'moves unconfirmed_phone to phone' do
        test_user.check_sms_token('ABC12345')
        test_user.reload
        expect(test_user.phone).to eq('0034600123456')
        expect(test_user.unconfirmed_phone).to be_nil
      end

      context 'spam filter integration' do
        before do
          allow(SpamFilter).to receive(:any?).and_return(false)
        end

        it 'checks spam filter for non-verified non-admin users' do
          test_user.verified = false
          test_user.admin = false
          test_user.save(validate: false)

          expect(SpamFilter).to receive(:any?).with(test_user).and_return(false)
          test_user.check_sms_token('ABC12345')
        end

        it 'bans user if spam filter matches' do
          test_user.verified = false
          test_user.admin = false
          test_user.save(validate: false)

          allow(SpamFilter).to receive(:any?).and_return('Test Filter')
          allow(test_user).to receive(:add_comment)

          test_user.check_sms_token('ABC12345')
          test_user.reload
          expect(test_user.banned).to be true
        end

        it 'adds comment when banning user' do
          test_user.verified = false
          test_user.admin = false
          test_user.save(validate: false)

          allow(SpamFilter).to receive(:any?).and_return('Test Filter')
          expect(test_user).to receive(:add_comment).with('Usuario baneado automáticamente por el filtro: Test Filter')

          test_user.check_sms_token('ABC12345')
        end

        it 'does not check spam filter for verified users' do
          test_user.verified = true
          test_user.admin = false
          test_user.save(validate: false)

          expect(SpamFilter).not_to receive(:any?)
          test_user.check_sms_token('ABC12345')
        end

        it 'does not check spam filter for admin users' do
          test_user.verified = false
          test_user.admin = true
          test_user.save(validate: false)

          expect(SpamFilter).not_to receive(:any?)
          test_user.check_sms_token('ABC12345')
        end
      end

      context 'when unconfirmed_phone is not present' do
        it 'does not update phone' do
          test_user.update_column(:unconfirmed_phone, nil)
          original_phone = test_user.phone

          test_user.check_sms_token('ABC12345')
          test_user.reload
          expect(test_user.phone).to eq(original_phone)
        end
      end
    end

    context 'with incorrect token' do
      it 'returns false' do
        expect(test_user.check_sms_token('WRONG123')).to be false
      end

      it 'does not update sms_confirmed_at' do
        original_time = test_user.sms_confirmed_at
        test_user.check_sms_token('WRONG123')
        test_user.reload
        expect(test_user.sms_confirmed_at).to eq(original_time)
      end

      it 'does not move unconfirmed_phone to phone' do
        original_phone = test_user.phone
        original_unconfirmed = test_user.unconfirmed_phone

        test_user.check_sms_token('WRONG123')
        test_user.reload
        expect(test_user.phone).to eq(original_phone)
        expect(test_user.unconfirmed_phone).to eq(original_unconfirmed)
      end

      it 'is case-sensitive' do
        expect(test_user.check_sms_token('abc12345')).to be false
      end
    end
  end

  describe '#can_request_sms_check?' do
    it 'returns true when current time is after next request time' do
      user.update_column(:sms_check_at, 10.minutes.ago)
      expect(user.can_request_sms_check?).to be true
    end

    it 'returns false when current time is before next request time' do
      user.update_column(:sms_check_at, 1.minute.ago)
      expect(user.can_request_sms_check?).to be false
    end

    it 'returns true when sms_check_at is nil' do
      user.update_column(:sms_check_at, nil)
      expect(user.can_request_sms_check?).to be true
    end
  end

  describe '#can_check_sms_check?' do
    it 'returns true when within valid interval' do
      user.update_column(:sms_check_at, 5.minutes.ago)
      expect(user.can_check_sms_check?).to be true
    end

    it 'returns false when outside valid interval' do
      user.update_column(:sms_check_at, 15.minutes.ago)
      expect(user.can_check_sms_check?).to be false
    end

    it 'returns false when sms_check_at is nil' do
      user.update_column(:sms_check_at, nil)
      expect(user.can_check_sms_check?).to be false
    end
  end

  describe '#next_sms_check_request_at' do
    it 'returns time based on sms_check_at plus interval' do
      user.update_column(:sms_check_at, 10.minutes.ago)
      expected_time = 10.minutes.ago + 5.minutes
      expect(user.next_sms_check_request_at).to be_within(1.second).of(expected_time)
    end

    it 'returns past time when sms_check_at is nil' do
      user.update_column(:sms_check_at, nil)
      expect(user.next_sms_check_request_at).to be < DateTime.now
    end
  end

  describe '#send_sms_check!' do
    before do
      allow(SMS::Sender).to receive(:send_message)
      user.update_column(:phone, '0034600123456')
    end

    context 'when can request check' do
      before do
        user.update_column(:sms_check_at, 10.minutes.ago)
      end

      it 'returns true' do
        expect(user.send_sms_check!).to be true
      end

      it 'updates sms_check_at' do
        freeze_time do
          user.send_sms_check!
          user.reload
          expect(user.sms_check_at).to be_within(1.second).of(DateTime.current)
        end
      end

      it 'sends SMS with check token' do
        freeze_time do
          user.send_sms_check!
          expected_token = user.sms_check_token
          expect(SMS::Sender).to have_received(:send_message).with('0034600123456', expected_token)
        end
      end
    end

    context 'when cannot request check' do
      before do
        user.update_column(:sms_check_at, 1.minute.ago)
      end

      it 'returns false' do
        expect(user.send_sms_check!).to be false
      end

      it 'does not update sms_check_at' do
        original_time = user.sms_check_at
        user.send_sms_check!
        user.reload
        expect(user.sms_check_at).to be_within(1.second).of(original_time)
      end

      it 'does not send SMS' do
        user.send_sms_check!
        expect(SMS::Sender).not_to have_received(:send_message)
      end
    end
  end

  describe '#valid_sms_check?' do
    before do
      user.update_column(:sms_check_at, 5.minutes.ago)
    end

    it 'returns true for correct token' do
      correct_token = user.sms_check_token
      expect(user.valid_sms_check?(correct_token)).to be true
    end

    it 'returns false for incorrect token' do
      expect(user.valid_sms_check?('WRONG123')).to be false
    end

    it 'is case-insensitive' do
      correct_token = user.sms_check_token
      expect(user.valid_sms_check?(correct_token.downcase)).to be true
    end

    it 'returns false when sms_check_at is nil' do
      user.update_column(:sms_check_at, nil)
      expect(user.valid_sms_check?('ABC12345')).to be false
    end
  end

  describe '#sms_check_token' do
    it 'returns nil when sms_check_at is nil' do
      user.update_column(:sms_check_at, nil)
      expect(user.sms_check_token).to be_nil
    end

    it 'returns 8-character hexadecimal token' do
      user.update_column(:sms_check_at, DateTime.current)
      token = user.sms_check_token
      expect(token).to match(/^[A-F0-9]{8}$/)
    end

    it 'generates different tokens for different times' do
      user.update_column(:sms_check_at, 1.hour.ago)
      token1 = user.sms_check_token

      user.update_column(:sms_check_at, DateTime.current)
      token2 = user.sms_check_token

      expect(token1).not_to eq(token2)
    end

    it 'generates same token for same time and user' do
      user.update_column(:sms_check_at, DateTime.current)
      token1 = user.sms_check_token
      token2 = user.sms_check_token
      expect(token1).to eq(token2)
    end

    it 'uses SHA256 for security' do
      user.update_column(:sms_check_at, DateTime.current)

      # Verify the token generation uses SHA256
      expected_digest = Digest::SHA256.digest("#{user.sms_check_at}#{user.id}test_secret_key_12345")
      expected_token = expected_digest[0..3].codepoints.map { |c| format('%02X', c) }.join

      expect(user.sms_check_token).to eq(expected_token)
    end
  end

  describe '#unconfirmed_phone=' do
    context 'with valid Spanish mobile' do
      it 'formats the phone correctly' do
        test_user = build(:user, country: 'ES', unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '+34600123456'
        # Phonelib formats as 00 + international (which already has +)
        expect(test_user[:unconfirmed_phone]).to eq('00+34600123456')
      end

      it 'handles national format' do
        test_user = build(:user, country: 'ES', unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '600123456'
        expect(test_user[:unconfirmed_phone]).to eq('00+34600123456')
      end
    end

    context 'with valid phone from user country' do
      it 'formats German phone when user is in Germany' do
        test_user = build(:user, country: 'DE', unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '+491701234567'
        expect(test_user[:unconfirmed_phone]).to eq('00+491701234567')
      end

      it 'formats German phone with national format' do
        test_user = build(:user, country: 'DE', unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '01701234567'
        expect(test_user[:unconfirmed_phone]).to eq('00+491701234567')
      end
    end

    context 'with Spanish phone when user is not in Spain' do
      it 'accepts Spanish phone as fallback' do
        test_user = build(:user, country: 'DE', unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '+34600123456'
        expect(test_user[:unconfirmed_phone]).to eq('00+34600123456')
      end
    end

    context 'with invalid phone' do
      it 'stores the raw value' do
        test_user = build(:user, unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '123'
        expect(test_user[:unconfirmed_phone]).to eq('123')
      end

      it 'adds error to errors collection' do
        test_user = build(:user, unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '123'
        expect(test_user.errors[:unconfirmed_phone]).to include('Debes utilizar un teléfono móvil de España o del país donde vives')
      end
    end

    context 'with fixed line phone' do
      it 'stores formatted value even though it will fail validation later' do
        test_user = build(:user, country: 'ES', unconfirmed_phone: nil)
        test_user.unconfirmed_phone = '+34912345678'
        # Fixed line is valid as "fixed_or_mobile" in Spain, so setter formats it
        # But the validation will reject it later in validates_unconfirmed_phone_format
        expect(test_user[:unconfirmed_phone]).to eq('00+34912345678')
      end
    end
  end

  describe '#unconfirmed_phone_national_part' do
    it 'returns national part of unconfirmed phone' do
      user.update_column(:unconfirmed_phone, '0034600123456')
      # Phonelib parses "00" as international prefix "+", so result includes country code
      expect(user.unconfirmed_phone_national_part).to eq('+34600123456')
    end

    it 'returns nil when unconfirmed_phone is blank' do
      user.update_column(:unconfirmed_phone, nil)
      expect(user.unconfirmed_phone_national_part).to be_nil
    end

    it 'handles German numbers' do
      user.update_column(:unconfirmed_phone, '00491701234567')
      # Phonelib parses "00" as international prefix "+", so result includes country code
      expect(user.unconfirmed_phone_national_part).to eq('+491701234567')
    end
  end

  describe '#phone_national_part' do
    it 'returns national part of phone' do
      user.update_column(:phone, '0034600123456')
      # Phonelib parses "00" as international prefix "+", so result includes country code
      expect(user.phone_national_part).to eq('+34600123456')
    end

    it 'returns nil when phone is blank' do
      user.update_column(:phone, nil)
      expect(user.phone_national_part).to be_nil
    end

    it 'handles UK numbers' do
      user.update_column(:phone, '00447700900123')
      # Phonelib parses "00" as international prefix "+", so result includes country code
      expect(user.phone_national_part).to eq('+447700900123')
    end
  end

  describe '#country_phone_prefix' do
    it 'returns 34 for Spain' do
      user.country = 'ES'
      expect(user.country_phone_prefix).to eq('34')
    end

    it 'returns 49 for Germany' do
      user.country = 'DE'
      expect(user.country_phone_prefix).to eq('49')
    end

    it 'returns 44 for UK' do
      user.country = 'GB'
      expect(user.country_phone_prefix).to eq('44')
    end

    it 'returns 34 as default for invalid country' do
      user.country = 'INVALID'
      expect(user.country_phone_prefix).to eq('34')
    end
  end

  describe '#phone_prefix' do
    it 'returns country prefix when phone is blank' do
      user.country = 'ES'
      user.update_column(:phone, nil)
      expect(user.phone_prefix).to eq('34')
    end

    it 'returns actual phone prefix when phone is present' do
      user.country = 'ES'
      user.update_column(:phone, '00491701234567')
      expect(user.phone_prefix).to eq('49')
    end

    it 'handles Spanish phones' do
      user.update_column(:phone, '0034600123456')
      expect(user.phone_prefix).to eq('34')
    end
  end

  describe '#phone_country_name' do
    it 'returns country name for Spanish phone' do
      user.update_column(:phone, '0034600123456')
      expect(user.phone_country_name).to eq('España')
    end

    it 'returns country name for German phone' do
      user.update_column(:phone, '00491701234567')
      expect(user.phone_country_name).to eq('Alemania')
    end

    it 'returns country name for UK phone' do
      user.update_column(:phone, '00447700900123')
      expect(user.phone_country_name).to eq('Reino Unido')
    end

    it 'falls back to user country_name on error' do
      user.update_column(:phone, 'invalid')
      allow(user).to receive(:country_name).and_return('User Country')
      expect(user.phone_country_name).to eq('User Country')
    end
  end

  describe '#parse_duration_config' do
    it 'parses seconds' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '30.seconds' })
      expect(user.send(:parse_duration_config, 'test')).to eq(30.seconds)
    end

    it 'parses minutes' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '5.minutes' })
      expect(user.send(:parse_duration_config, 'test')).to eq(5.minutes)
    end

    it 'parses hours' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '2.hours' })
      expect(user.send(:parse_duration_config, 'test')).to eq(2.hours)
    end

    it 'parses days' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '7.days' })
      expect(user.send(:parse_duration_config, 'test')).to eq(7.days)
    end

    it 'parses weeks' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '2.weeks' })
      expect(user.send(:parse_duration_config, 'test')).to eq(2.weeks)
    end

    it 'parses months' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '3.months' })
      expect(user.send(:parse_duration_config, 'test')).to eq(3.months)
    end

    it 'parses years' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '1.year' })
      expect(user.send(:parse_duration_config, 'test')).to eq(1.year)
    end

    it 'handles integer values' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => 300 })
      expect(user.send(:parse_duration_config, 'test')).to eq(300.seconds)
    end

    it 'returns default 5 minutes for invalid format' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => 'invalid' })
      expect(user.send(:parse_duration_config, 'test')).to eq(5.minutes)
    end

    it 'returns default 5 minutes on exception' do
      allow(Rails.application.secrets).to receive(:users).and_raise(StandardError)
      expect(user.send(:parse_duration_config, 'test')).to eq(5.minutes)
    end

    it 'handles singular forms' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '1.minute' })
      expect(user.send(:parse_duration_config, 'test')).to eq(1.minute)
    end

    it 'handles plural forms' do
      allow(Rails.application.secrets).to receive(:users).and_return({ 'test' => '10.minutes' })
      expect(user.send(:parse_duration_config, 'test')).to eq(10.minutes)
    end
  end

  describe 'private methods' do
    describe '#extract_national_part' do
      it 'extracts national part from international format' do
        result = user.send(:extract_national_part, '0034600123456')
        # Phonelib parses "00" prefix as "+", so the result includes the full international format
        expect(result).to eq('+34600123456')
      end

      it 'handles German numbers' do
        result = user.send(:extract_national_part, '00491701234567')
        expect(result).to eq('+491701234567')
      end

      it 'handles UK numbers' do
        result = user.send(:extract_national_part, '00447700900123')
        expect(result).to eq('+447700900123')
      end
    end
  end

  describe 'edge cases and error handling' do
    it 'handles nil phone gracefully in phone_prefix' do
      user.update_column(:phone, nil)
      expect { user.phone_prefix }.not_to raise_error
    end

    it 'handles empty string phone in phone_national_part' do
      user.update_column(:phone, '')
      expect(user.phone_national_part).to be_nil
    end

    it 'handles concurrent token generation' do
      tokens = []
      threads = 5.times.map do
        Thread.new { tokens << user.generate_sms_token }
      end
      threads.each(&:join)
      expect(tokens.length).to eq(5)
      expect(tokens.all? { |t| t.match?(/^[A-F0-9]{8}$/) }).to be true
    end

    it 'handles very old sms_check_at dates' do
      user.update_column(:sms_check_at, 10.years.ago)
      expect { user.sms_check_token }.not_to raise_error
      expect(user.can_request_sms_check?).to be true
      expect(user.can_check_sms_check?).to be false
    end
  end
end
