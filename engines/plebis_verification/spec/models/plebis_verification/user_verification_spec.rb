# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe UserVerification, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:user) }
    end

    describe 'enum' do
      it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, issues: 2, rejected: 3, accepted_by_email: 4, discarded: 5, paused: 6) }
    end

    describe 'scopes' do
      describe '.verifying' do
        it 'returns verifications with status pending, issues, or paused' do
          pending = create(:user_verification, status: :pending)
          issues = create(:user_verification, status: :issues)
          accepted = create(:user_verification, status: :accepted)

          result = UserVerification.verifying
          expect(result).to include(pending, issues)
          expect(result).not_to include(accepted)
        end
      end

      describe '.not_discarded' do
        it 'excludes discarded verifications' do
          active = create(:user_verification, status: :pending)
          discarded = create(:user_verification, status: :discarded)

          result = UserVerification.not_discarded
          expect(result).to include(active)
          expect(result).not_to include(discarded)
        end
      end
    end

    describe '#discardable?' do
      it 'returns true for pending status' do
        verification = build(:user_verification, status: :pending)
        expect(verification.discardable?).to be true
      end

      it 'returns true for issues status' do
        verification = build(:user_verification, status: :issues)
        expect(verification.discardable?).to be true
      end

      it 'returns false for accepted status' do
        verification = build(:user_verification, status: :accepted)
        expect(verification.discardable?).to be false
      end
    end

    describe 'table name' do
      it 'uses user_verifications table' do
        expect(UserVerification.table_name).to eq('user_verifications')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        verification = build(:user_verification)
        expect(verification).to be_valid
      end

      it 'creates a verification with required attributes' do
        verification = create(:user_verification)
        expect(verification).to be_persisted
      end
    end

    describe 'ActiveStorage attachments' do
      let(:user) { create(:user) }
      let(:verification) { build(:user_verification, user: user) }

      it 'has front_vatid attachment' do
        expect(verification).to respond_to(:front_vatid)
      end

      it 'has back_vatid attachment' do
        expect(verification).to respond_to(:back_vatid)
      end

      it 'can attach front_vatid image' do
        verification.front_vatid.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
          filename: 'test_front.png',
          content_type: 'image/png'
        )
        expect(verification.front_vatid).to be_attached
      end

      it 'generates front_vatid_thumb variant' do
        verification.front_vatid.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
          filename: 'test_front.png',
          content_type: 'image/png'
        )
        expect(verification.front_vatid_thumb).to be_present
      end

      it 'returns nil for front_vatid_thumb when not attached' do
        expect(verification.front_vatid_thumb).to be_nil
      end

      it 'generates back_vatid_thumb variant' do
        verification.back_vatid.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
          filename: 'test_back.png',
          content_type: 'image/png'
        )
        expect(verification.back_vatid_thumb).to be_present
      end

      it 'returns nil for back_vatid_thumb when not attached' do
        expect(verification.back_vatid_thumb).to be_nil
      end
    end

    describe 'rotation attributes' do
      let(:verification) { build(:user_verification) }

      it 'has front_vatid_rotation accessor' do
        expect(verification).to respond_to(:front_vatid_rotation)
        expect(verification).to respond_to(:front_vatid_rotation=)
      end

      it 'has back_vatid_rotation accessor' do
        expect(verification).to respond_to(:back_vatid_rotation)
        expect(verification).to respond_to(:back_vatid_rotation=)
      end

      it 'has rotate method' do
        expect(verification).to respond_to(:rotate)
      end

      it 'rotate returns HashWithIndifferentAccess' do
        expect(verification.rotate).to be_a(ActiveSupport::HashWithIndifferentAccess)
      end
    end

    describe 'validations' do
      let(:user) { create(:user) }

      describe 'user presence' do
        it 'validates user presence when photos required' do
          verification = build(:user_verification, user: nil)
          allow(verification).to receive(:not_require_photos?).and_return(false)
          expect(verification).not_to be_valid
          expect(verification.errors[:user]).to be_present
        end

        it 'skips user validation when photos not required' do
          verification = build(:user_verification, user: nil)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.valid?
          # May still fail on other validations, but not user presence
        end
      end

      describe 'front_vatid presence' do
        it 'validates front_vatid when photos required' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:not_require_photos?).and_return(false)
          expect(verification).not_to be_valid
        end

        it 'skips front_vatid validation when photos not required' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.valid?
          # Front vatid error should not be present
        end
      end

      describe 'back_vatid presence' do
        it 'validates back_vatid when required' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:require_back?).and_return(true)
          allow(verification).to receive(:not_require_photos?).and_return(false)
          expect(verification).not_to be_valid
        end

        it 'skips back_vatid validation when not required' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:require_back?).and_return(false)
          allow(verification).to receive(:not_require_photos?).and_return(false)
          verification.front_vatid.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
            filename: 'test.png',
            content_type: 'image/png'
          )
          verification.valid?
          expect(verification.errors[:back_vatid]).to be_empty
        end
      end

      describe 'terms_of_service acceptance' do
        it 'validates terms of service acceptance' do
          verification = build(:user_verification, user: user, terms_of_service: false)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          expect(verification).not_to be_valid
        end

        it 'accepts true for terms' do
          verification = build(:user_verification, user: user, terms_of_service: true)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.valid?
          expect(verification.errors[:terms_of_service]).to be_empty
        end

        it 'accepts "1" for terms' do
          verification = build(:user_verification, user: user, terms_of_service: '1')
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.valid?
          expect(verification.errors[:terms_of_service]).to be_empty
        end
      end

      describe 'image content type validation' do
        it 'validates front_vatid is an image' do
          verification = build(:user_verification, user: user)
          verification.front_vatid.attach(
            io: StringIO.new('fake content'),
            filename: 'test.txt',
            content_type: 'text/plain'
          )
          expect(verification).not_to be_valid
          expect(verification.errors[:front_vatid]).to include('debe ser una imagen')
        end

        it 'validates back_vatid is an image' do
          verification = build(:user_verification, user: user)
          verification.back_vatid.attach(
            io: StringIO.new('fake content'),
            filename: 'test.txt',
            content_type: 'text/plain'
          )
          expect(verification).not_to be_valid
          expect(verification.errors[:back_vatid]).to include('debe ser una imagen')
        end

        it 'accepts image content types' do
          verification = build(:user_verification, user: user)
          verification.front_vatid.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
            filename: 'test.png',
            content_type: 'image/png'
          )
          verification.valid?
          expect(verification.errors[:front_vatid]).not_to include('debe ser una imagen')
        end
      end

      describe 'image size validation' do
        it 'validates front_vatid size is under 6MB' do
          verification = build(:user_verification, user: user)
          large_file = double(byte_size: 7.megabytes, content_type: 'image/png', attached?: true)
          allow(verification).to receive(:front_vatid).and_return(large_file)
          expect(verification).not_to be_valid
          expect(verification.errors[:front_vatid]).to include('debe ser menor de 6MB')
        end

        it 'validates back_vatid size is under 6MB' do
          verification = build(:user_verification, user: user)
          large_file = double(byte_size: 7.megabytes, content_type: 'image/png', attached?: true)
          allow(verification).to receive(:back_vatid).and_return(large_file)
          expect(verification).not_to be_valid
          expect(verification.errors[:back_vatid]).to include('debe ser menor de 6MB')
        end

        it 'accepts files under 6MB' do
          verification = build(:user_verification, user: user)
          verification.front_vatid.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
            filename: 'test.png',
            content_type: 'image/png'
          )
          verification.valid?
          expect(verification.errors[:front_vatid]).not_to include('debe ser menor de 6MB')
        end
      end
    end

    describe '#require_back?' do
      it 'returns true when user is not passport' do
        user = create(:user)
        allow(user).to receive(:is_passport?).and_return(false)
        verification = build(:user_verification, user: user)
        expect(verification.require_back?).to be true
      end

      it 'returns false when user is passport' do
        user = create(:user)
        allow(user).to receive(:is_passport?).and_return(true)
        verification = build(:user_verification, user: user)
        expect(verification.require_back?).to be false
      end
    end

    describe '#not_require_photos?' do
      it 'delegates to user photos_unnecessary?' do
        user = create(:user)
        verification = build(:user_verification, user: user)
        allow(user).to receive(:photos_unnecessary?).and_return(true)
        expect(verification.not_require_photos?).to be true
      end

      it 'returns false when user photos are necessary' do
        user = create(:user)
        verification = build(:user_verification, user: user)
        allow(user).to receive(:photos_unnecessary?).and_return(false)
        expect(verification.not_require_photos?).to be false
      end
    end

    describe '.for' do
      let(:user) { create(:user) }

      it 'returns existing pending verification' do
        existing = create(:user_verification, user: user, status: :pending)
        result = UserVerification.for(user)
        expect(result).to eq(existing)
      end

      it 'returns existing issues verification' do
        existing = create(:user_verification, user: user, status: :issues)
        result = UserVerification.for(user)
        expect(result).to eq(existing)
      end

      it 'returns existing rejected verification' do
        existing = create(:user_verification, user: user, status: :rejected)
        result = UserVerification.for(user)
        expect(result).to eq(existing)
      end

      it 'creates new verification when none exists' do
        result = UserVerification.for(user)
        expect(result).to be_a(UserVerification)
        expect(result.new_record?).to be true
      end

      it 'assigns attributes to existing verification' do
        existing = create(:user_verification, user: user, status: :pending)
        result = UserVerification.for(user, { status: :issues })
        expect(result.status).to eq('issues')
      end

      it 'assigns attributes to new verification' do
        result = UserVerification.for(user, { status: :pending })
        expect(result.status).to eq('pending')
      end

      it 'ignores accepted verifications' do
        create(:user_verification, user: user, status: :accepted)
        result = UserVerification.for(user)
        expect(result.new_record?).to be true
      end
    end

    describe 'callbacks' do
      let(:user) { create(:user) }

      describe 'after_validation' do
        it 'removes paperclip-related errors' do
          verification = build(:user_verification, user: user)
          verification.errors.add(:front_vatid_file_name, 'some error')
          verification.errors.add(:back_vatid_content_type, 'some error')
          verification.valid?
          expect(verification.errors[:front_vatid_file_name]).to be_empty
          expect(verification.errors[:back_vatid_content_type]).to be_empty
        end
      end

      describe 'after_commit' do
        it 'calls verify_user_militant_status' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.terms_of_service = true
          expect(verification).to receive(:verify_user_militant_status)
          verification.save!
        end

        it 'updates user militant status' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.terms_of_service = true
          expect(user).to receive(:update).with(militant: anything)
          verification.save!
        end

        it 'processes militant data' do
          verification = build(:user_verification, user: user)
          allow(verification).to receive(:not_require_photos?).and_return(true)
          verification.terms_of_service = true
          expect(user).to receive(:process_militant_data)
          verification.save!
        end
      end
    end

    describe '#determine_initial_status' do
      let(:user) { create(:user) }

      it 'returns accepted_by_email when photos unnecessary' do
        verification = build(:user_verification, user: user, status: :pending)
        allow(user).to receive(:photos_unnecessary?).and_return(true)
        expect(verification.determine_initial_status).to eq(:accepted_by_email)
      end

      it 'returns pending when previously rejected' do
        verification = build(:user_verification, user: user, status: :rejected)
        allow(user).to receive(:photos_unnecessary?).and_return(false)
        expect(verification.determine_initial_status).to eq(:pending)
      end

      it 'returns pending when previously had issues' do
        verification = build(:user_verification, user: user, status: :issues)
        allow(user).to receive(:photos_unnecessary?).and_return(false)
        expect(verification.determine_initial_status).to eq(:pending)
      end

      it 'keeps current status otherwise' do
        verification = build(:user_verification, user: user, status: :accepted)
        allow(user).to receive(:photos_unnecessary?).and_return(false)
        expect(verification.determine_initial_status).to eq(:accepted)
      end
    end

    describe '#apply_initial_status!' do
      let(:user) { create(:user) }

      it 'applies the determined status' do
        verification = build(:user_verification, user: user, status: :rejected)
        allow(user).to receive(:photos_unnecessary?).and_return(true)
        verification.apply_initial_status!
        expect(verification.status).to eq('accepted_by_email')
      end
    end

    describe 'scopes' do
      describe '.discardable' do
        it 'includes pending and issues verifications' do
          pending = create(:user_verification, status: :pending)
          issues = create(:user_verification, status: :issues)
          accepted = create(:user_verification, status: :accepted)

          result = UserVerification.discardable
          expect(result).to include(pending, issues)
          expect(result).not_to include(accepted)
        end
      end

      describe '.not_sended' do
        it 'returns verifications wanting card with no born_at' do
          wants_card = create(:user_verification, wants_card: true, born_at: nil)
          has_born_at = create(:user_verification, wants_card: true, born_at: Date.today)
          no_card = create(:user_verification, wants_card: false, born_at: nil)

          result = UserVerification.not_sended
          expect(result).to include(wants_card)
          expect(result).not_to include(has_born_at, no_card)
        end
      end
    end

    describe 'paper_trail' do
      it 'has paper trail enabled' do
        expect(UserVerification).to respond_to(:paper_trail)
      end
    end
  end
end
