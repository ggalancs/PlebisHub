# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe Notice, type: :model do
    describe 'validations' do
      it 'validates presence of title' do
        notice = Notice.new(title: nil)
        expect(notice.valid?).to be false
        expect(notice.errors[:title]).to include("no puede estar en blanco")
      end

      it 'validates presence of body' do
        notice = Notice.new(body: nil)
        expect(notice.valid?).to be false
        expect(notice.errors[:body]).to include("no puede estar en blanco")
      end

      describe 'link validation' do
        it 'allows blank link' do
          notice = build(:notice, link: '')
          expect(notice).to be_valid
        end

        it 'allows nil link' do
          notice = build(:notice, link: nil)
          expect(notice).to be_valid
        end

        it 'allows valid http URL' do
          notice = build(:notice, link: 'http://example.com')
          expect(notice).to be_valid
        end

        it 'allows valid https URL' do
          notice = build(:notice, link: 'https://example.com')
          expect(notice).to be_valid
        end

        it 'rejects invalid URL' do
          notice = build(:notice, link: 'not-a-url')
          expect(notice).not_to be_valid
          expect(notice.errors[:link]).to be_present
        end

        it 'rejects ftp URLs' do
          notice = build(:notice, link: 'ftp://example.com')
          expect(notice).not_to be_valid
        end
      end
    end

    describe 'default scope' do
      it 'orders by created_at descending' do
        old_notice = create(:notice, created_at: 2.days.ago)
        new_notice = create(:notice, created_at: 1.hour.ago)
        middle_notice = create(:notice, created_at: 1.day.ago)

        result = Notice.all.pluck(:id)
        expect(result).to eq([new_notice.id, middle_notice.id, old_notice.id])
      end
    end

    describe 'pagination' do
      it 'paginates with 5 items per page' do
        expect(Notice.default_per_page).to eq(5)
      end
    end

    describe 'scopes' do
      describe '.sent' do
        it 'returns notices with sent_at timestamp' do
          sent_notice = create(:notice, :sent)
          pending_notice = create(:notice, :pending)

          expect(Notice.sent).to include(sent_notice)
          expect(Notice.sent).not_to include(pending_notice)
        end

        it 'returns multiple sent notices' do
          sent1 = create(:notice, sent_at: 1.hour.ago)
          sent2 = create(:notice, sent_at: 2.hours.ago)
          create(:notice, :pending)

          result = Notice.sent
          expect(result).to include(sent1, sent2)
          expect(result.count).to eq(2)
        end
      end

      describe '.pending' do
        it 'returns notices without sent_at timestamp' do
          sent_notice = create(:notice, :sent)
          pending_notice = create(:notice, :pending)

          expect(Notice.pending).to include(pending_notice)
          expect(Notice.pending).not_to include(sent_notice)
        end

        it 'returns multiple pending notices' do
          pending1 = create(:notice, sent_at: nil)
          pending2 = create(:notice, sent_at: nil)
          create(:notice, :sent)

          result = Notice.pending
          expect(result).to include(pending1, pending2)
          expect(result.count).to eq(2)
        end
      end

      describe '.active' do
        it 'includes notices without expiration' do
          notice = create(:notice, final_valid_at: nil)
          expect(Notice.active).to include(notice)
        end

        it 'includes notices with future expiration' do
          notice = create(:notice, final_valid_at: 1.week.from_now)
          expect(Notice.active).to include(notice)
        end

        it 'excludes expired notices' do
          notice = create(:notice, final_valid_at: 1.day.ago)
          expect(Notice.active).not_to include(notice)
        end

        it 'handles time boundaries correctly' do
          future_notice = create(:notice, final_valid_at: 1.second.from_now)
          expect(Notice.active).to include(future_notice)
        end
      end

      describe '.expired' do
        it 'includes notices with past expiration' do
          notice = create(:notice, final_valid_at: 1.day.ago)
          expect(Notice.expired).to include(notice)
        end

        it 'excludes notices with future expiration' do
          notice = create(:notice, final_valid_at: 1.week.from_now)
          expect(Notice.expired).not_to include(notice)
        end

        it 'excludes notices without expiration' do
          notice = create(:notice, final_valid_at: nil)
          expect(Notice.expired).not_to include(notice)
        end

        it 'includes notices expired just now' do
          past_notice = create(:notice, final_valid_at: 1.second.ago)
          expect(Notice.expired).to include(past_notice)
        end
      end
    end

    describe '#broadcast!' do
      let(:notice) { create(:notice, title: 'Test', body: 'Body', link: 'https://example.com') }

      before do
        allow(notice).to receive(:broadcast_gcm)
      end

      it 'calls broadcast_gcm with title, body, and link' do
        expect(notice).to receive(:broadcast_gcm).with('Test', 'Body', 'https://example.com')
        notice.broadcast!
      end

      it 'updates sent_at timestamp' do
        freeze_time do
          expect {
            notice.broadcast!
          }.to change { notice.reload.sent_at }.from(nil).to(be_within(1.second).of(Time.current))
        end
      end

      it 'uses update_column to avoid callbacks' do
        expect(notice).to receive(:update_column).with(:sent_at, kind_of(DateTime))
        notice.broadcast!
      end
    end

    describe '#broadcast_gcm' do
      let(:notice) { build(:notice) }

      before do
        allow(Rails.application).to receive(:secrets).and_return(
          double(gcm: { 'key' => 'test-key' })
        )
        allow(GCM).to receive(:send_notification)
        allow(PlebisCms::NoticeRegistrar).to receive(:pluck).with(:registration_id).and_return([])
      end

      it 'sets GCM host' do
        expect(GCM).to receive(:host=).with('https://android.googleapis.com/gcm/send')
        notice.broadcast_gcm('Title', 'Message', 'Link')
      end

      it 'sets GCM format to json' do
        expect(GCM).to receive(:format=).with(:json)
        notice.broadcast_gcm('Title', 'Message', 'Link')
      end

      it 'sets GCM key from secrets' do
        expect(GCM).to receive(:key=).with('test-key')
        notice.broadcast_gcm('Title', 'Message', 'Link')
      end

      it 'sends notification with correct data structure' do
        allow(PlebisCms::NoticeRegistrar).to receive(:pluck).and_return(['device1', 'device2'])
        
        expected_data = {
          title: 'Title',
          message: 'Message',
          url: 'Link',
          msgcnt: '1',
          soundname: 'beep.wav'
        }
        
        expect(GCM).to receive(:send_notification).with(['device1', 'device2'], expected_data)
        notice.broadcast_gcm('Title', 'Message', 'Link')
      end

      it 'handles batches of 1000 devices' do
        devices = (1..2500).map { |i| "device#{i}" }
        allow(PlebisCms::NoticeRegistrar).to receive(:pluck).and_return(devices)
        
        expect(GCM).to receive(:send_notification).exactly(3).times
        notice.broadcast_gcm('Title', 'Message', 'Link')
      end
    end

    describe '#has_sent / #sent?' do
      it 'returns false when sent_at is nil' do
        notice = build(:notice, sent_at: nil)
        expect(notice.has_sent).to be false
        expect(notice.sent?).to be false
      end

      it 'returns true when sent_at is present' do
        notice = build(:notice, sent_at: 1.hour.ago)
        expect(notice.has_sent).to be true
        expect(notice.sent?).to be true
      end

      it 'sent? is an alias for has_sent' do
        notice = build(:notice, sent_at: 1.hour.ago)
        expect(notice.method(:sent?)).to eq(notice.method(:has_sent))
      end
    end

    describe '#active?' do
      it 'returns true when final_valid_at is nil' do
        notice = build(:notice, final_valid_at: nil)
        expect(notice.active?).to be true
      end

      it 'returns true when final_valid_at is in the future' do
        notice = build(:notice, final_valid_at: 1.week.from_now)
        expect(notice.active?).to be true
      end

      it 'returns false when final_valid_at is in the past' do
        notice = build(:notice, final_valid_at: 1.day.ago)
        expect(notice.active?).to be false
      end

      it 'handles time boundaries correctly' do
        freeze_time do
          future_notice = build(:notice, final_valid_at: 1.second.from_now)
          past_notice = build(:notice, final_valid_at: 1.second.ago)
          
          expect(future_notice.active?).to be true
          expect(past_notice.active?).to be false
        end
      end
    end

    describe '#expired?' do
      it 'returns false when final_valid_at is nil' do
        notice = build(:notice, final_valid_at: nil)
        expect(notice.expired?).to be false
      end

      it 'returns false when final_valid_at is in the future' do
        notice = build(:notice, final_valid_at: 1.week.from_now)
        expect(notice.expired?).to be false
      end

      it 'returns true when final_valid_at is in the past' do
        notice = build(:notice, final_valid_at: 1.day.ago)
        expect(notice.expired?).to be true
      end

      it 'is inverse of active?' do
        notice = build(:notice, final_valid_at: 1.day.ago)
        expect(notice.expired?).to eq(!notice.active?)
        
        notice.final_valid_at = 1.week.from_now
        expect(notice.expired?).to eq(!notice.active?)
      end
    end

    describe 'table name' do
      it 'uses notices table' do
        expect(Notice.table_name).to eq('notices')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        notice = build(:notice)
        expect(notice).to be_valid
      end

      it 'creates a notice with all required attributes' do
        notice = create(:notice)
        expect(notice).to be_persisted
        expect(notice.title).to be_present
        expect(notice.body).to be_present
      end
    end
  end
end
