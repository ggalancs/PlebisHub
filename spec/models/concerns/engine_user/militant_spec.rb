# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Militant, type: :model do
  let(:vote_circle) { create(:vote_circle) }
  let(:user) { create(:user, vote_circle: vote_circle, document_type: 1, document_vatid: '12345678Z') }

  describe 'associations' do
    it 'has many militant_records with dependent destroy' do
      association = user.class.reflect_on_association(:militant_records)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe '#still_militant?' do
    context 'when all conditions are met' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end

    context 'when user is not verified' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user is not in vote circle' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user has no collaboration and is not exempt' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user is exempt from payment' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(true)
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end
  end

  describe '#militant_at?' do
    let(:test_date) { Date.new(2024, 6, 1) }

    context 'when all conditions were met at the given date' do
      before do
        user.update(
          vote_circle_id: vote_circle.id,
          vote_circle_changed_at: test_date - 10.days
        )
        create(:user_verification, user: user, status: 'accepted', updated_at: test_date - 5.days)
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 0, created_at: test_date - 3.days)
      end

      it 'returns true' do
        expect(user.militant_at?(test_date)).to be true
      end
    end

    context 'when user had no vote circle at that date' do
      before do
        user.update(vote_circle_id: nil, vote_circle_changed_at: nil)
      end

      it 'returns false' do
        expect(user.militant_at?(test_date)).to be false
      end
    end

    context 'with different collaboration statuses' do
      before do
        user.update(
          vote_circle_id: vote_circle.id,
          vote_circle_changed_at: test_date - 10.days
        )
        create(:user_verification, user: user, status: 'accepted', updated_at: test_date - 5.days)
      end

      it 'returns true for status 0 (incomplete)' do
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 0, created_at: test_date - 3.days)
        expect(user.militant_at?(test_date)).to be true
      end

      it 'returns true for status 2 (unconfirmed)' do
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 2, created_at: test_date - 3.days)
        expect(user.militant_at?(test_date)).to be true
      end

      it 'returns true for status 3 (active)' do
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 3, created_at: test_date - 3.days)
        expect(user.militant_at?(test_date)).to be true
      end
    end
  end

  describe '#get_not_militant_detail' do
    context 'when user is already militant' do
      before do
        user.update(militant: true)
        allow(user).to receive(:still_militant?).and_return(true)
      end

      it 'returns nil' do
        expect(user.get_not_militant_detail).to be_nil
      end
    end

    context 'when user is not verified' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns verification error' do
        expect(user.get_not_militant_detail).to include('No esta verificado')
      end
    end

    context 'when user is not in a circle' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns circle error' do
        expect(user.get_not_militant_detail).to include('No esta inscrito en un circulo')
      end
    end

    context 'when user has no collaboration and is not exempt' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns collaboration error' do
        expect(user.get_not_militant_detail).to include('No tiene colaboración económica periódica')
      end
    end

    context 'when multiple conditions are not met' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns combined errors with proper formatting' do
        result = user.get_not_militant_detail
        expect(result).to include('No esta verificado')
        expect(result).to include('No esta inscrito en un circulo')
        expect(result).to include(' y ')
      end
    end
  end

  describe '#process_militant_data' do
    let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

    before do
      allow(UsersMailer).to receive(:new_militant_email).and_return(mailer_double)
    end

    context 'when becoming militant for the first time' do
      before do
        allow(user).to receive(:still_militant?).and_return(true)
        user.militant_records.destroy_all
      end

      it 'sends militant email' do
        expect(UsersMailer).to receive(:new_militant_email).with(user.id)
        user.process_militant_data
      end
    end

    context 'when losing militant status' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        create(:militant_record, user: user, is_militant: true)
      end

      it 'does not send email' do
        expect(UsersMailer).not_to receive(:new_militant_email)
        user.process_militant_data
      end
    end

    context 'when regaining militant status' do
      before do
        allow(user).to receive(:still_militant?).and_return(true)
        create(:militant_record, user: user, is_militant: false)
      end

      it 'sends militant email' do
        expect(UsersMailer).to receive(:new_militant_email).with(user.id)
        user.process_militant_data
      end
    end

    context 'when remaining militant' do
      before do
        allow(user).to receive(:still_militant?).and_return(true)
        create(:militant_record, user: user, is_militant: true)
      end

      it 'does not send email' do
        expect(UsersMailer).not_to receive(:new_militant_email)
        user.process_militant_data
      end
    end
  end

  describe '#militant_records_management' do
    let(:now) { DateTime.now }

    before do
      allow(DateTime).to receive(:now).and_return(now)
    end

    context 'when user is verified' do
      before do
        user.update(verified: true)
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
        create(:user_verification, user: user, updated_at: 1.day.ago)
      end

      it 'sets begin_verified date' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.begin_verified).not_to be_nil
      end

      it 'keeps end_verified as nil' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.end_verified).to be_nil
      end
    end

    context 'when user loses verification' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
        create(:militant_record, user: user, begin_verified: 1.week.ago, end_verified: nil)
      end

      it 'sets end_verified date' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.end_verified).not_to be_nil
      end
    end

    context 'when user is in vote circle' do
      before do
        user.update(vote_circle: vote_circle, vote_circle_changed_at: 1.week.ago)
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'sets begin_in_vote_circle date' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.begin_in_vote_circle).not_to be_nil
      end

      it 'stores vote circle name' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.vote_circle_name).to eq(vote_circle.name)
      end
    end

    context 'when user is exempt from payment' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(true)
      end

      it 'sets payment_type to 0' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.payment_type).to eq(0)
      end

      it 'sets amount to 0' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.amount).to eq(0)
      end
    end

    context 'when user has active collaboration' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 3, created_at: 1.week.ago)
      end

      it 'sets payment_type to 1' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.payment_type).to eq(1)
      end

      it 'stores collaboration amount' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.amount).to eq(500)
      end
    end
  end

  # ============================================================================
  # INTEGRATION TESTS - These tests use real data without stubs to ensure
  # actual code paths are covered in the concern
  # ============================================================================

  describe 'integration tests (without stubs)' do
    let(:vote_circle) { create(:vote_circle, name: 'Test Circle') }
    let(:user) do
      create(:user,
             vote_circle: vote_circle,
             vote_circle_changed_at: 2.weeks.ago,
             document_type: 1,
             document_vatid: '12345678Z',
             verified: true)
    end

    # Helper to create a collaboration with status set properly (bypasses callback)
    def create_collaboration_with_status(user:, status:, **attrs)
      collab = create(:collaboration, user: user, **attrs)
      collab.update_column(:status, status)
      collab
    end

    describe '#still_militant? integration' do
      context 'with verified user in vote circle with collaboration' do
        before do
          create(:user_verification, user: user, status: 'accepted')
          create(:collaboration, :active, user: user, amount: 500, frequency: 1)
        end

        it 'returns true when all conditions are met' do
          expect(user.still_militant?).to be true
        end
      end

      context 'with verified user in vote circle but no collaboration' do
        before do
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'returns false without collaboration' do
          expect(user.still_militant?).to be false
        end
      end

      context 'with user not in vote circle' do
        before do
          user.update(vote_circle_id: nil)
          create(:user_verification, user: user, status: 'accepted')
          create(:collaboration, :active, user: user, amount: 500, frequency: 1)
        end

        it 'returns false without vote circle' do
          expect(user.still_militant?).to be false
        end
      end

      context 'with exempt from payment flag' do
        before do
          create(:user_verification, user: user, status: 'accepted')
          user.update!(exempt_from_payment: true)
        end

        it 'returns true when exempt from payment' do
          expect(user.still_militant?).to be true
        end
      end
    end

    describe '#militant_at? integration' do
      let(:check_date) { Date.current }

      context 'with all historical conditions met' do
        before do
          user.update(vote_circle_changed_at: 1.month.ago)
          create(:user_verification, user: user, status: 'accepted', updated_at: 2.weeks.ago)
          create_collaboration_with_status(user: user, status: 3, amount: 500, frequency: 1, created_at: 1.week.ago)
        end

        it 'returns true for current date' do
          expect(user.militant_at?(check_date)).to be true
        end

        it 'returns false for date before conditions were met' do
          expect(user.militant_at?(2.months.ago)).to be false
        end
      end

      context 'with pending verification status' do
        before do
          user.update(verified: false, vote_circle_changed_at: 1.month.ago)
          create(:user_verification, user: user, status: 'pending', updated_at: 2.weeks.ago)
          # Status 0 is acceptable for militant_at? check (status [0, 2, 3])
          create(:collaboration, user: user, amount: 500, frequency: 1, created_at: 1.week.ago)
        end

        it 'returns true because pending verification counts' do
          expect(user.militant_at?(check_date)).to be true
        end
      end

      context 'with exempt from payment and militant record' do
        before do
          user.update!(vote_circle_changed_at: 1.month.ago, exempt_from_payment: true)
          create(:user_verification, user: user, status: 'accepted', updated_at: 2.weeks.ago)
          create(:militant_record, user: user, payment_type: 0, begin_payment: 3.weeks.ago)
        end

        it 'returns true considering exempt payment date' do
          expect(user.militant_at?(check_date)).to be true
        end
      end

      context 'with status 2 collaboration' do
        before do
          user.update(vote_circle_changed_at: 1.month.ago)
          create(:user_verification, user: user, status: 'accepted', updated_at: 2.weeks.ago)
          create(:collaboration, :unconfirmed, user: user, amount: 500, frequency: 1, created_at: 1.week.ago)
        end

        it 'returns true for status 2 (unconfirmed) collaboration' do
          expect(user.militant_at?(check_date)).to be true
        end
      end
    end

    describe '#get_not_militant_detail integration' do
      context 'when user is already militant and still meets criteria' do
        before do
          user.update(militant: true)
          create(:user_verification, user: user, status: 'accepted')
          create(:collaboration, :active, user: user, amount: 500, frequency: 1)
        end

        it 'returns nil for current militant' do
          expect(user.get_not_militant_detail).to be_nil
        end
      end

      context 'when user is not militant but meets criteria' do
        before do
          user.update(militant: false)
          create(:user_verification, user: user, status: 'accepted')
          create(:collaboration, :active, user: user, amount: 500, frequency: 1)
        end

        it 'updates militant flag and returns nil' do
          result = user.get_not_militant_detail
          expect(result).to be_nil
          expect(user.reload.militant).to be true
        end
      end

      context 'when user is not verified' do
        before do
          user.update(militant: false, verified: false)
        end

        it 'returns verification error message' do
          result = user.get_not_militant_detail
          expect(result).to include('No esta verificado')
        end
      end

      context 'when user has no vote circle' do
        before do
          user.update(militant: false, vote_circle_id: nil)
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'returns circle error message' do
          result = user.get_not_militant_detail
          expect(result).to include('No esta inscrito en un circulo')
        end
      end

      context 'when user has no collaboration and is not exempt' do
        before do
          user.update(militant: false)
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'returns collaboration error message' do
          result = user.get_not_militant_detail
          expect(result).to include('No tiene colaboración económica periódica')
        end
      end

      context 'when multiple conditions are not met' do
        before do
          user.update(militant: false, verified: false, vote_circle_id: nil)
        end

        it 'returns combined error messages' do
          result = user.get_not_militant_detail
          expect(result).to include('No esta verificado')
          expect(result).to include('No esta inscrito en un circulo')
          expect(result).to include(' y ')
        end
      end
    end

    describe '#process_militant_data integration' do
      let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

      before do
        allow(UsersMailer).to receive(:new_militant_email).and_return(mailer_double)
      end

      context 'when user becomes militant for the first time' do
        before do
          user.militant_records.destroy_all
          create(:user_verification, user: user, status: 'accepted')
          create(:collaboration, :active, user: user, amount: 500, frequency: 1)
        end

        it 'creates militant record and sends email' do
          expect(UsersMailer).to receive(:new_militant_email).with(user.id)
          expect { user.process_militant_data }.to change { user.militant_records.count }.by(1)
        end
      end

      context 'when user loses militant status' do
        before do
          create(:militant_record, user: user, is_militant: true)
          # User no longer meets requirements (no collaboration)
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'creates new record with is_militant false' do
          user.process_militant_data
          record = user.militant_records.order(id: :desc).first
          expect(record.is_militant).to be false
        end
      end
    end

    describe '#militant_records_management integration' do
      context 'when user is fully verified with vote circle and collaboration' do
        before do
          user.update(vote_circle_changed_at: 1.week.ago)
          create(:user_verification, user: user, status: 'accepted', updated_at: 2.weeks.ago)
          create(:collaboration, :active, user: user, amount: 500, frequency: 1, created_at: 3.days.ago)
        end

        it 'creates a complete militant record' do
          expect { user.militant_records_management(true) }.to change { user.militant_records.count }.by(1)
          record = user.militant_records.order(id: :desc).first

          expect(record.is_militant).to be true
          expect(record.begin_verified).not_to be_nil
          expect(record.begin_in_vote_circle).not_to be_nil
          expect(record.vote_circle_name).to eq('Test Circle')
          expect(record.begin_payment).not_to be_nil
          expect(record.payment_type).to eq(1)
          expect(record.amount).to eq(500)
        end
      end

      context 'when user is exempt from payment' do
        before do
          user.update!(exempt_from_payment: true, vote_circle_changed_at: 1.week.ago)
          create(:user_verification, user: user, status: 'accepted', updated_at: 2.weeks.ago)
        end

        it 'creates record with payment_type 0 and amount 0' do
          user.militant_records_management(true)
          record = user.militant_records.order(id: :desc).first

          expect(record.payment_type).to eq(0)
          expect(record.amount).to eq(0)
        end
      end

      context 'when continuing in the same vote circle' do
        let!(:existing_record) do
          create(:militant_record,
                 user: user,
                 vote_circle_name: 'Test Circle',
                 begin_in_vote_circle: 2.weeks.ago,
                 end_in_vote_circle: nil)
        end

        before do
          user.update(vote_circle_changed_at: 1.week.ago)
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'preserves the begin_in_vote_circle date' do
          user.militant_records_management(false)
          record = user.militant_records.order(id: :desc).first

          # Se compara contra el valor recargado: Ruby guarda nanosegundos y
          # PostgreSQL solo microsegundos, asi que el objeto en memoria y el leido
          # de la base difieren salvo que la fraccion caiga redonda. En macOS casi
          # nunca salta y en Linux si.
          expect(record.begin_in_vote_circle).to eq(existing_record.reload.begin_in_vote_circle)
        end
      end

      context 'when changing vote circles' do
        let(:new_circle) { create(:vote_circle, name: 'New Circle') }
        let!(:existing_record) do
          create(:militant_record,
                 user: user,
                 vote_circle_name: 'Old Circle',
                 begin_in_vote_circle: 1.month.ago,
                 end_in_vote_circle: nil)
        end

        before do
          user.update(vote_circle: new_circle, vote_circle_changed_at: 1.day.ago)
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'updates end_in_vote_circle on previous record and creates new record' do
          user.militant_records_management(false)

          existing_record.reload
          expect(existing_record.end_in_vote_circle).not_to be_nil

          new_record = user.militant_records.order(id: :desc).first
          expect(new_record.vote_circle_name).to eq('New Circle')
          # Igual que arriba: ambos lados deben venir de la base para comparar
          # con la misma precision
          expect(new_record.begin_in_vote_circle).to eq(user.reload.vote_circle_changed_at)
        end
      end

      context 'when losing vote circle membership' do
        let!(:existing_record) do
          create(:militant_record,
                 user: user,
                 vote_circle_name: 'Test Circle',
                 begin_in_vote_circle: 1.month.ago,
                 end_in_vote_circle: nil)
        end

        before do
          user.update(vote_circle_id: nil)
          create(:user_verification, user: user, status: 'accepted')
        end

        it 'sets end_in_vote_circle on the new record' do
          user.militant_records_management(false)
          record = user.militant_records.order(id: :desc).first

          expect(record.end_in_vote_circle).not_to be_nil
          expect(record.vote_circle_name).to eq('Test Circle')
        end
      end

      context 'when user loses verification' do
        let!(:existing_record) do
          create(:militant_record,
                 user: user,
                 begin_verified: 1.month.ago,
                 end_verified: nil)
        end

        before do
          user.update(verified: false)
          # No verification or rejected verification
        end

        it 'sets end_verified on the new record' do
          user.militant_records_management(false)
          record = user.militant_records.order(id: :desc).first

          expect(record.end_verified).not_to be_nil
        end
      end

      context 'when losing payment (no collaboration, not exempt)' do
        let!(:existing_record) do
          create(:militant_record,
                 user: user,
                 begin_payment: 1.month.ago,
                 end_payment: nil,
                 payment_type: 1,
                 amount: 500)
        end

        before do
          user.update(vote_circle_changed_at: 1.week.ago)
          create(:user_verification, user: user, status: 'accepted')
          # No collaboration created
        end

        it 'sets end_payment on the new record' do
          user.militant_records_management(false)
          record = user.militant_records.order(id: :desc).first

          expect(record.end_payment).not_to be_nil
        end
      end

      context 'when record has not changed' do
        let!(:existing_record) do
          create(:militant_record,
                 user: user,
                 is_militant: false,
                 begin_verified: nil,
                 end_verified: nil,
                 begin_in_vote_circle: nil,
                 end_in_vote_circle: nil,
                 vote_circle_name: nil,
                 begin_payment: nil,
                 end_payment: nil,
                 payment_type: nil,
                 amount: nil)
        end

        before do
          user.update(vote_circle_id: nil, verified: false)
        end

        it 'does not create a duplicate record' do
          expect { user.militant_records_management(false) }.not_to change { user.militant_records.count }
        end
      end

      context 'with status 2 collaboration' do
        before do
          user.update(vote_circle_changed_at: 1.week.ago)
          create(:user_verification, user: user, status: 'accepted')
          create(:collaboration, :unconfirmed, user: user, amount: 400, frequency: 1, created_at: 5.days.ago)
        end

        it 'finds the collaboration with status 2' do
          user.militant_records_management(true)
          record = user.militant_records.order(id: :desc).first

          expect(record.payment_type).to eq(1)
          expect(record.amount).to eq(400)
        end
      end
    end
  end
end
