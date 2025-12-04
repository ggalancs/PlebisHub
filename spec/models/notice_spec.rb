# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCms::Notice, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid notice' do
      notice = build(:notice)
      expect(notice).to be_valid, 'Factory should create a valid notice'
    end

    it 'creates valid sent notice' do
      notice = build(:notice, :sent)
      expect(notice).to be_valid
      expect(notice.sent_at).not_to be_nil
    end

    it 'creates valid active notice' do
      notice = build(:notice, :active)
      expect(notice).to be_valid
      expect(notice).to be_active
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    context 'title' do
      it 'requires title' do
        notice = build(:notice, title: nil)
        expect(notice).not_to be_valid
        expect(notice.errors[:title]).to include('no puede estar en blanco')
      end

      it 'accepts valid title' do
        notice = build(:notice, title: 'Important Announcement')
        expect(notice).to be_valid
      end

      it 'rejects empty string title' do
        notice = build(:notice, title: '')
        expect(notice).not_to be_valid
        expect(notice.errors[:title]).to include('no puede estar en blanco')
      end
    end

    context 'body' do
      it 'requires body' do
        notice = build(:notice, body: nil)
        expect(notice).not_to be_valid
        expect(notice.errors[:body]).to include('no puede estar en blanco')
      end

      it 'accepts valid body' do
        notice = build(:notice, body: 'This is a detailed message for all users.')
        expect(notice).to be_valid
      end

      it 'rejects empty string body' do
        notice = build(:notice, body: '')
        expect(notice).not_to be_valid
        expect(notice.errors[:body]).to include('no puede estar en blanco')
      end
    end

    context 'link' do
      it 'accepts nil link' do
        notice = build(:notice, link: nil)
        expect(notice).to be_valid
      end

      it 'accepts blank link' do
        notice = build(:notice, link: '')
        expect(notice).to be_valid
      end

      it 'accepts valid http URL' do
        notice = build(:notice, link: 'http://example.com/page')
        expect(notice).to be_valid
      end

      it 'accepts valid https URL' do
        notice = build(:notice, link: 'https://example.com/page')
        expect(notice).to be_valid
      end

      it 'rejects invalid URL format' do
        notice = build(:notice, link: 'not-a-url')
        expect(notice).not_to be_valid
        expect(notice.errors[:link]).to include('must be a valid URL')
      end

      it 'rejects URL without protocol' do
        notice = build(:notice, link: 'example.com')
        expect(notice).not_to be_valid
        expect(notice.errors[:link]).to include('must be a valid URL')
      end

      it 'rejects invalid protocol' do
        notice = build(:notice, link: 'ftp://example.com')
        expect(notice).not_to be_valid
        expect(notice.errors[:link]).to include('must be a valid URL')
      end
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates notice with valid attributes' do
      expect { create(:notice) }.to change(Notice, :count).by(1)
    end

    it 'reads notice attributes correctly' do
      notice = create(:notice,
                      title: 'Test Title',
                      body: 'Test Body',
                      link: 'https://example.com')

      found_notice = Notice.find(notice.id)
      expect(found_notice.title).to eq('Test Title')
      expect(found_notice.body).to eq('Test Body')
      expect(found_notice.link).to eq('https://example.com')
    end

    it 'updates notice attributes' do
      notice = create(:notice, title: 'Original Title')
      notice.update(title: 'Updated Title')

      expect(notice.reload.title).to eq('Updated Title')
    end

    it 'does not update with invalid attributes' do
      notice = create(:notice, title: 'Valid Title')
      notice.update(title: nil)

      expect(notice).not_to be_valid
      expect(notice.reload.title).to eq('Valid Title')
    end

    it 'deletes notice' do
      notice = create(:notice)
      expect { notice.destroy }.to change(Notice, :count).by(-1)
    end
  end

  # ====================
  # DEFAULT SCOPE TESTS
  # ====================

  describe 'default scope' do
    it 'orders by created_at DESC' do
      old_notice = create(:notice, created_at: 2.days.ago)
      new_notice = create(:notice, created_at: 1.day.ago)
      newest_notice = create(:notice, created_at: 1.hour.ago)

      notices = PlebisCms::Notice.all.to_a

      expect(notices[0]).to eq(newest_notice)
      expect(notices[1]).to eq(new_notice)
      expect(notices[2]).to eq(old_notice)
    end

    it 'maintains order after updates' do
      first = create(:notice, created_at: 3.days.ago)
      second = create(:notice, created_at: 2.days.ago)

      first.update(title: 'Updated')

      notices = PlebisCms::Notice.all.to_a
      expect(notices[0]).to eq(second)
      expect(notices[1]).to eq(first)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.sent' do
      it 'returns only sent notices' do
        sent_notice = create(:notice, :sent)
        pending_notice = create(:notice, :pending)

        sent_notices = PlebisCms::Notice.sent

        expect(sent_notices).to include(sent_notice)
        expect(sent_notices).not_to include(pending_notice)
      end

      it 'returns empty when no sent notices exist' do
        create(:notice, :pending)
        create(:notice, :pending)

        expect(PlebisCms::Notice.sent).to be_empty
      end
    end

    describe '.pending' do
      it 'returns only pending notices' do
        sent_notice = create(:notice, :sent)
        pending_notice = create(:notice, :pending)

        pending_notices = PlebisCms::Notice.pending

        expect(pending_notices).to include(pending_notice)
        expect(pending_notices).not_to include(sent_notice)
      end

      it 'returns empty when no pending notices exist' do
        create(:notice, :sent)
        create(:notice, :sent)

        expect(PlebisCms::Notice.pending).to be_empty
      end
    end

    describe '.active' do
      it 'returns notices without expiration' do
        active_notice = create(:notice, final_valid_at: nil)
        expired_notice = create(:notice, :expired)

        active_notices = PlebisCms::Notice.active

        expect(active_notices).to include(active_notice)
        expect(active_notices).not_to include(expired_notice)
      end

      it 'returns notices not yet expired' do
        active_notice = create(:notice, final_valid_at: 1.day.from_now)
        expired_notice = create(:notice, :expired)

        active_notices = PlebisCms::Notice.active

        expect(active_notices).to include(active_notice)
        expect(active_notices).not_to include(expired_notice)
      end

      it 'handles edge case at expiration time' do
        almost_expired = create(:notice, final_valid_at: 1.second.from_now)

        expect(PlebisCms::Notice.active).to include(almost_expired)

        # Simulate time passing
        travel 2.seconds do
          expect(PlebisCms::Notice.active).not_to include(almost_expired)
        end
      end
    end

    describe '.expired' do
      it 'returns only expired notices' do
        active_notice = create(:notice, :active)
        expired_notice = create(:notice, :expired)

        expired_notices = PlebisCms::Notice.expired

        expect(expired_notices).to include(expired_notice)
        expect(expired_notices).not_to include(active_notice)
      end

      it 'does not include notices without expiration' do
        without_expiration = create(:notice, final_valid_at: nil)
        expired = create(:notice, :expired)

        expired_notices = PlebisCms::Notice.expired

        expect(expired_notices).to include(expired)
        expect(expired_notices).not_to include(without_expiration)
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#has_sent' do
      it 'returns true when sent_at is present' do
        notice = create(:notice, :sent)
        expect(notice.has_sent).to be_truthy
      end

      it 'returns false when sent_at is nil' do
        notice = create(:notice, :pending)
        expect(notice.has_sent).to be_falsey
      end
    end

    describe '#sent?' do
      it 'is an alias for has_sent' do
        notice = create(:notice, :sent)
        expect(notice.sent?).to eq(notice.has_sent)
      end

      it 'returns true when sent' do
        notice = create(:notice, :sent)
        expect(notice.sent?).to be_truthy
      end

      it 'returns false when pending' do
        notice = create(:notice, :pending)
        expect(notice.sent?).to be_falsey
      end
    end

    describe '#active?' do
      it 'returns true when final_valid_at is nil' do
        notice = create(:notice, final_valid_at: nil)
        expect(notice).to be_active
      end

      it 'returns true when final_valid_at is in future' do
        notice = create(:notice, final_valid_at: 1.day.from_now)
        expect(notice).to be_active
      end

      it 'returns false when final_valid_at is in past' do
        notice = create(:notice, :expired)
        expect(notice).not_to be_active
      end

      it 'handles current time edge case' do
        notice = create(:notice, final_valid_at: 1.second.from_now)
        expect(notice).to be_active
      end
    end

    describe '#expired?' do
      it 'returns false when active' do
        notice = create(:notice, :active)
        expect(notice).not_to be_expired
      end

      it 'returns true when past final_valid_at' do
        notice = create(:notice, :expired)
        expect(notice).to be_expired
      end

      it 'returns false when no expiration set' do
        notice = create(:notice, final_valid_at: nil)
        expect(notice).not_to be_expired
      end
    end

    # NOTE: broadcast! and broadcast_gcm methods require external GCM service
    # We test them with proper mocking to achieve coverage

    describe '#broadcast!' do
      it 'calls broadcast_gcm with correct parameters' do
        notice = create(:notice, title: 'Test Title', body: 'Test Body', link: 'https://example.com')

        # Mock the broadcast_gcm method
        allow(notice).to receive(:broadcast_gcm)

        notice.broadcast!

        expect(notice).to have_received(:broadcast_gcm).with('Test Title', 'Test Body', 'https://example.com')
      end

      it 'updates sent_at timestamp' do
        notice = create(:notice, sent_at: nil)

        # Mock the broadcast_gcm method to avoid external dependencies
        allow(notice).to receive(:broadcast_gcm)

        expect { notice.broadcast! }.to change { notice.reload.sent_at }.from(nil)
        expect(notice.sent_at).not_to be_nil
      end

      it 'uses update_column to avoid callbacks' do
        notice = create(:notice)

        # Mock broadcast_gcm
        allow(notice).to receive(:broadcast_gcm)

        # Verify update_column is called (not update or update_attribute)
        expect(notice).to receive(:update_column).with(:sent_at, kind_of(DateTime))

        notice.broadcast!
      end
    end

    describe '#broadcast_gcm' do
      let(:gcm_double) { class_double('GCM').as_stubbed_const }

      before do
        # Mock GCM as a module/class with setters and methods
        allow(gcm_double).to receive(:host=)
        allow(gcm_double).to receive(:format=)
        allow(gcm_double).to receive(:key=)
        allow(gcm_double).to receive(:send_notification)
      end

      it 'exists and accepts correct parameters' do
        notice = create(:notice)
        expect(notice).to respond_to(:broadcast_gcm)
        # Method signature verification
        expect(notice.method(:broadcast_gcm).arity).to eq(3)
      end

      it 'configures GCM with correct settings' do
        notice = create(:notice)

        # Mock Rails secrets
        allow(Rails.application).to receive(:secrets).and_return(
          OpenStruct.new(gcm: { 'key' => 'test_gcm_key' })
        )

        notice.broadcast_gcm('Title', 'Message', 'https://link.com')

        expect(gcm_double).to have_received(:host=).with('https://android.googleapis.com/gcm/send')
        expect(gcm_double).to have_received(:format=).with(:json)
        expect(gcm_double).to have_received(:key=).with('test_gcm_key')
      end

      it 'sends notification to registrars in groups of 1000' do
        notice = create(:notice)

        # Create test registrars
        registration_ids = (1..2500).map { |i| "reg_id_#{i}" }
        allow(PlebisCms::NoticeRegistrar).to receive(:pluck).with(:registration_id).and_return(registration_ids)

        # Mock Rails secrets
        allow(Rails.application).to receive(:secrets).and_return(
          OpenStruct.new(gcm: { 'key' => 'test_key' })
        )

        notice.broadcast_gcm('Test Title', 'Test Message', 'https://test.com')

        # Should be called 3 times (1000 + 1000 + 500)
        expect(gcm_double).to have_received(:send_notification).exactly(3).times
      end

      it 'includes correct data in notification payload' do
        notice = create(:notice)

        # Create a single registrar
        allow(PlebisCms::NoticeRegistrar).to receive(:pluck).with(:registration_id).and_return(['reg_id_1'])

        # Mock Rails secrets
        allow(Rails.application).to receive(:secrets).and_return(
          OpenStruct.new(gcm: { 'key' => 'test_key' })
        )

        expected_data = {
          title: 'Test Title',
          message: 'Test Message',
          url: 'https://example.com',
          msgcnt: '1',
          soundname: 'beep.wav'
        }

        notice.broadcast_gcm('Test Title', 'Test Message', 'https://example.com')

        # in_groups_of(1000) will pad a single item with nils
        # So we expect an array of 1000 elements where first is 'reg_id_1' and rest are nil
        expect(gcm_double).to have_received(:send_notification) do |destination, data|
          expect(destination[0]).to eq('reg_id_1')
          expect(destination.compact).to eq(['reg_id_1'])
          expect(data).to eq(expected_data)
        end
      end

      it 'handles nil link in notification' do
        notice = create(:notice)

        allow(PlebisCms::NoticeRegistrar).to receive(:pluck).with(:registration_id).and_return(['reg_id_1'])
        allow(Rails.application).to receive(:secrets).and_return(
          OpenStruct.new(gcm: { 'key' => 'test_key' })
        )

        expected_data = {
          title: 'Test',
          message: 'Message',
          url: nil,
          msgcnt: '1',
          soundname: 'beep.wav'
        }

        notice.broadcast_gcm('Test', 'Message', nil)

        # in_groups_of(1000) will pad a single item with nils
        expect(gcm_double).to have_received(:send_notification) do |destination, data|
          expect(destination[0]).to eq('reg_id_1')
          expect(destination.compact).to eq(['reg_id_1'])
          expect(data).to eq(expected_data)
        end
      end
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles very long title' do
      long_title = 'A' * 1000
      notice = build(:notice, title: long_title)
      # Should not crash
      notice.valid?
      expect(notice).not_to be_nil
    end

    it 'handles very long body' do
      long_body = 'B' * 10_000
      notice = build(:notice, body: long_body)
      # Should not crash
      notice.valid?
      expect(notice).not_to be_nil
    end

    it 'handles special characters in title' do
      notice = build(:notice, title: "Special chars: @\#$% & <> 特殊")
      expect(notice).to be_valid
    end

    it 'handles special characters in body' do
      notice = build(:notice, body: 'Body with émojis 🎉 and symbols © ® ™')
      expect(notice).to be_valid
    end

    it 'handles very long URL' do
      long_url = "https://example.com/#{'a' * 1000}"
      notice = build(:notice, link: long_url)
      expect(notice).to be_valid
    end
  end

  # ====================
  # PAGINATION TESTS
  # ====================

  describe 'pagination' do
    it 'paginates with 5 items per page' do
      10.times { create(:notice) }

      first_page = Notice.page(1)
      expect(first_page.count).to eq(5)

      second_page = Notice.page(2)
      expect(second_page.count).to eq(5)
    end

    it 'returns correct page count' do
      12.times { create(:notice) }

      # 12 items / 5 per page = 3 pages
      expect(Notice.page.total_pages).to eq(3)
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'handles sent active notices' do
      notice = create(:notice, :sent_active)

      expect(notice).to be_sent
      expect(notice).to be_active
      expect(PlebisCms::Notice.sent).to include(notice)
      expect(PlebisCms::Notice.active).to include(notice)
    end

    it 'handles pending expired notices' do
      notice = create(:notice, :pending, :expired)

      expect(notice).not_to be_sent
      expect(notice).to be_expired
      expect(PlebisCms::Notice.pending).to include(notice)
      expect(PlebisCms::Notice.expired).to include(notice)
    end

    it 'filters sent and active notices' do
      sent_active = create(:notice, :sent_active)
      sent_expired = create(:notice, :sent_expired)
      pending_active = create(:notice, :pending_active)

      results = PlebisCms::Notice.sent.active

      expect(results).to include(sent_active)
      expect(results).not_to include(sent_expired)
      expect(results).not_to include(pending_active)
    end
  end
end
