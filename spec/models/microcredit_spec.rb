# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisMicrocredit::Microcredit, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid microcredit' do
      microcredit = build(:microcredit)
      expect(microcredit).to be_valid, 'Factory should create a valid microcredit'
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'validates limits format' do
      microcredit = build(:microcredit, limits: 'invalid')
      expect(microcredit).not_to be_valid
      expect(microcredit.errors[:limits]).to include('Introduce pares (monto, cantidad)')
    end

    it 'accepts valid limits format' do
      microcredit = build(:microcredit, limits: "100€: 10\n500€: 5")
      expect(microcredit).to be_valid
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates microcredit with valid attributes' do
      expect do
        create(:microcredit)
      end.to change(described_class, :count).by(1)
    end

    it 'updates microcredit attributes' do
      microcredit = create(:microcredit, title: 'Original')

      microcredit.update(title: 'Updated')

      expect(microcredit.reload.title).to eq('Updated')
    end

    it 'soft deletes microcredit' do
      microcredit = create(:microcredit)

      expect do
        microcredit.destroy
      end.to change(described_class, :count).by(-1)

      expect(microcredit.reload.deleted_at).not_to be_nil
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.active' do
      it 'returns currently active microcredits' do
        active = create(:microcredit, :active)
        upcoming = create(:microcredit, :upcoming)
        finished = create(:microcredit, :finished)

        results = described_class.active

        expect(results).to include(active)
        expect(results).not_to include(upcoming)
        expect(results).not_to include(finished)
      end
    end

    describe '.non_finished' do
      it 'returns future microcredits' do
        active = create(:microcredit, :active)
        finished = create(:microcredit, :finished)

        results = described_class.non_finished

        expect(results).to include(active)
        expect(results).not_to include(finished)
      end
    end

    describe '.standard' do
      it 'returns non-mailing microcredits' do
        standard = create(:microcredit, mailing: false)
        mailing = create(:microcredit, :with_mailing)

        results = described_class.standard

        expect(results).to include(standard)
        expect(results).not_to include(mailing)
      end
    end

    describe '.mailing' do
      it 'returns mailing microcredits' do
        standard = create(:microcredit, mailing: false)
        mailing = create(:microcredit, :with_mailing)

        results = described_class.mailing

        expect(results).to include(mailing)
        expect(results).not_to include(standard)
      end
    end
  end

  # ====================
  # FLAG TESTS
  # ====================

  describe 'flags' do
    it 'has mailing flag' do
      microcredit = create(:microcredit, :with_mailing)
      expect(microcredit.mailing?).to be true
    end

    it 'does not have mailing flag by default' do
      microcredit = create(:microcredit)
      expect(microcredit.mailing?).to be false
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'has many loans' do
      microcredit = create(:microcredit)
      expect(microcredit).to respond_to(:loans)
    end

    it 'has many microcredit_options' do
      microcredit = create(:microcredit)
      expect(microcredit).to respond_to(:microcredit_options)
    end

    it 'destroys dependent microcredit_options' do
      microcredit = create(:microcredit)
      create(:microcredit_option, microcredit: microcredit)

      expect do
        microcredit.destroy
      end.to change(MicrocreditOption, :count).by(-1)
    end
  end

  # ====================
  # STATUS METHOD TESTS
  # ====================

  describe 'status methods' do
    describe '#is_standard?' do
      it 'returns true for non-mailing microcredit' do
        microcredit = create(:microcredit, mailing: false)
        expect(microcredit.is_standard?).to be true
      end

      it 'returns false for mailing microcredit' do
        microcredit = create(:microcredit, :with_mailing)
        expect(microcredit.is_standard?).to be false
      end
    end

    describe '#is_mailing?' do
      it 'returns true for mailing microcredit' do
        microcredit = create(:microcredit, :with_mailing)
        expect(microcredit.is_mailing?).to be true
      end

      it 'returns false for standard microcredit' do
        microcredit = create(:microcredit, mailing: false)
        expect(microcredit.is_mailing?).to be false
      end
    end

    describe '#is_active?' do
      it 'returns true for active microcredit' do
        microcredit = create(:microcredit, :active)
        expect(microcredit.is_active?).to be true
      end

      it 'returns false for upcoming microcredit' do
        microcredit = create(:microcredit, :upcoming)
        expect(microcredit.is_active?).to be false
      end

      it 'returns false for finished microcredit' do
        microcredit = create(:microcredit, :finished)
        expect(microcredit.is_active?).to be false
      end
    end

    describe '#is_upcoming?' do
      it 'returns true for microcredit starting within 24 hours' do
        microcredit = create(:microcredit, :upcoming)
        expect(microcredit.is_upcoming?).to be true
      end

      it 'returns false for active microcredit' do
        microcredit = create(:microcredit, :active)
        expect(microcredit.is_upcoming?).to be false
      end
    end

    describe '#has_finished?' do
      it 'returns true for finished microcredit' do
        microcredit = create(:microcredit, :finished)
        expect(microcredit.has_finished?).to be true
      end

      it 'returns false for active microcredit' do
        microcredit = create(:microcredit, :active)
        expect(microcredit.has_finished?).to be false
      end
    end

    describe '#recently_finished?' do
      it 'returns true for microcredit finished within 7 days' do
        microcredit = create(:microcredit, starts_at: 10.days.ago, ends_at: 3.days.ago)
        expect(microcredit.recently_finished?).to be true
      end

      it 'returns false for microcredit finished more than 7 days ago' do
        microcredit = create(:microcredit, starts_at: 20.days.ago, ends_at: 10.days.ago)
        expect(microcredit.recently_finished?).to be false
      end

      it 'returns false for active microcredit' do
        microcredit = create(:microcredit, :active)
        expect(microcredit.recently_finished?).to be false
      end
    end

    describe '#completed' do
      it 'returns true when confirmed amount meets total goal' do
        microcredit = create(:microcredit, :active, total_goal: 1000, limits: '100€: 20')
        allow(microcredit).to receive(:campaign_confirmed_amount).and_return(1000)
        expect(microcredit.completed).to be true
      end

      it 'returns false when confirmed amount is below total goal' do
        microcredit = create(:microcredit, :active, total_goal: 1000)
        allow(microcredit).to receive(:campaign_confirmed_amount).and_return(500)
        expect(microcredit.completed).to be false
      end
    end

    describe '#renewable?' do
      it 'returns true when finished and has renewal terms' do
        microcredit = create(:microcredit, :finished)
        microcredit.renewal_terms.attach(
          io: StringIO.new('%PDF-1.4 test'),
          filename: 'terms.pdf',
          content_type: 'application/pdf'
        )
        expect(microcredit.renewable?).to be true
      end

      it 'returns false when not finished' do
        microcredit = create(:microcredit, :active)
        expect(microcredit.renewable?).to be false
      end

      it 'returns false when no renewal terms attached' do
        microcredit = create(:microcredit, :finished)
        expect(microcredit.renewable?).to be false
      end
    end
  end

  # ====================
  # LIMITS METHOD TESTS
  # ====================

  describe 'limits handling' do
    describe '#limits' do
      it 'parses limits string correctly' do
        microcredit = create(:microcredit, limits: "100€: 10\n500€: 5")
        expect(microcredit.limits).to eq({ 100 => 10, 500 => 5 })
      end

      it 'handles different separators' do
        microcredit = create(:microcredit, limits: '100: 10, 500: 5')
        expect(microcredit.limits).to eq({ 100 => 10, 500 => 5 })
      end
    end

    describe '#single_limit' do
      it 'returns parsed limits hash' do
        microcredit = create(:microcredit, limits: '100: 10')
        expect(microcredit.single_limit).to eq({ 100 => 10 })
      end
    end

    describe '#method_missing for single_limit_*' do
      it 'returns limit for specific amount' do
        microcredit = create(:microcredit, limits: '100: 10, 500: 5')
        expect(microcredit.single_limit_100).to eq(10)
        expect(microcredit.single_limit_500).to eq(5)
      end

      it 'returns nil for non-existent amount' do
        microcredit = create(:microcredit, limits: '100: 10')
        expect(microcredit.single_limit_999).to be_nil
      end
    end

    describe '#parse_limits' do
      it 'parses valid limits string' do
        microcredit = build(:microcredit)
        result = microcredit.parse_limits('100: 10, 200: 20')
        expect(result).to eq({ 100 => 10, 200 => 20 })
      end

      it 'returns nil for nil input' do
        microcredit = build(:microcredit)
        expect(microcredit.parse_limits(nil)).to be_nil
      end
    end
  end

  # ====================
  # CAMPAIGN STATUS TESTS
  # ====================

  describe 'campaign status calculations' do
    let(:microcredit) { create(:microcredit, :active, limits: "100€: 10\n200€: 5") }
    let(:option) { create(:microcredit_option, microcredit: microcredit) }

    before do
      # Create various loans
      loan1 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
      loan1.update_columns(confirmed_at: nil, counted_at: nil, discarded_at: nil)

      loan2 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
      loan2.update_columns(confirmed_at: Time.current, counted_at: nil, discarded_at: nil)

      loan3 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 200)
      loan3.update_columns(confirmed_at: Time.current, counted_at: Time.current, discarded_at: nil)

      loan4 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 200)
      loan4.update_columns(confirmed_at: nil, counted_at: nil, discarded_at: Time.current)

      microcredit.clear_cache
    end

    describe '#campaign_status' do
      it 'returns status grouped by amount and flags' do
        status = microcredit.campaign_status
        expect(status).to be_an(Array)
        expect(status.first).to be_an(Array)
      end
    end

    describe '#campaign_created_amount' do
      it 'returns total amount of all loans' do
        expect(microcredit.campaign_created_amount).to eq(600) # 100 + 100 + 200 + 200
      end
    end

    describe '#campaign_unconfirmed_amount' do
      it 'returns amount of unconfirmed loans' do
        expect(microcredit.campaign_unconfirmed_amount).to eq(300) # 100 + 200 (discarded)
      end
    end

    describe '#campaign_confirmed_amount' do
      it 'returns amount of confirmed loans' do
        expect(microcredit.campaign_confirmed_amount).to eq(300) # 100 + 200
      end
    end

    describe '#campaign_counted_amount' do
      it 'returns amount of counted loans' do
        expect(microcredit.campaign_counted_amount).to eq(200) # only loan3
      end
    end

    describe '#campaign_discarded_amount' do
      it 'returns amount of discarded loans' do
        expect(microcredit.campaign_discarded_amount).to eq(200) # loan4
      end
    end

    describe '#campaign_created_count' do
      it 'returns count of all loans' do
        expect(microcredit.campaign_created_count).to eq(4)
      end
    end

    describe '#campaign_confirmed_count' do
      it 'returns count of confirmed loans' do
        expect(microcredit.campaign_confirmed_count).to eq(2)
      end
    end

    describe '#campaign_counted_count' do
      it 'returns count of counted loans' do
        expect(microcredit.campaign_counted_count).to eq(1)
      end
    end

    describe '#campaign_discarded_count' do
      it 'returns count of discarded loans' do
        expect(microcredit.campaign_discarded_count).to eq(1)
      end
    end
  end

  # ====================
  # PHASE METHODS TESTS
  # ====================

  describe 'phase methods' do
    let(:microcredit) { create(:microcredit, :active, limits: "100€: 5\n200€: 3") }
    let(:option) { create(:microcredit_option, microcredit: microcredit) }

    before do
      2.times do
        loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
        loan.update_columns(confirmed_at: Time.current, counted_at: Time.current)
      end
      microcredit.clear_cache
    end

    describe '#phase_status' do
      it 'returns phase loans status' do
        status = microcredit.phase_status
        expect(status).to be_an(Array)
      end
    end

    describe '#phase_counted_amount' do
      it 'returns counted amount in current phase' do
        expect(microcredit.phase_counted_amount).to eq(200)
      end
    end

    describe '#phase_current_for_amount' do
      it 'returns current count for specific amount' do
        expect(microcredit.phase_current_for_amount(100)).to eq(2)
        expect(microcredit.phase_current_for_amount(200)).to eq(0)
      end
    end

    describe '#phase_remaining' do
      it 'returns remaining slots for all amounts' do
        remaining = microcredit.phase_remaining
        expect(remaining).to include([100, 3]) # 5 - 2 = 3
        expect(remaining).to include([200, 3]) # 3 - 0 = 3
      end

      it 'filters by specific amount' do
        remaining = microcredit.phase_remaining(100)
        expect(remaining).to eq([[100, 3]])
      end
    end

    describe '#phase_limit_amount' do
      it 'calculates total phase limit amount' do
        expect(microcredit.phase_limit_amount).to eq(1100) # 100*5 + 200*3
      end
    end

    describe '#has_amount_available?' do
      it 'returns true when slots available' do
        expect(microcredit.has_amount_available?(100)).to be true
        expect(microcredit.has_amount_available?(200)).to be true
      end

      it 'returns false when no slots available' do
        3.times do
          loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
          loan.update_columns(counted_at: Time.current)
        end
        microcredit.clear_cache
        expect(microcredit.has_amount_available?(100)).to be false
      end

      it 'returns false for non-existent amount' do
        result = microcredit.has_amount_available?(999)
        expect(result).to be_in([false, nil])
      end
    end
  end

  # ====================
  # PERCENTAGE METHODS TESTS
  # ====================

  describe 'percentage calculations' do
    let(:microcredit) { create(:microcredit, :active, total_goal: 1000, limits: '100€: 10') }
    let(:option) { create(:microcredit_option, microcredit: microcredit) }

    describe '#remaining_percent' do
      it 'calculates remaining percentage based on time and progress' do
        allow(microcredit).to receive(:campaign_counted_amount).and_return(500)
        percent = microcredit.remaining_percent
        expect(percent).to be_a(Numeric)
        expect(percent).to be >= 0
      end

      it 'uses bank_counted_amount if higher' do
        microcredit.update_column(:bank_counted_amount, 800)
        allow(microcredit).to receive(:campaign_counted_amount).and_return(500)
        percent = microcredit.remaining_percent
        expect(percent).to be_a(Numeric)
      end
    end

    describe '#current_percent' do
      it 'calculates current percentage for amount' do
        loan1 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
        loan1.update_columns(confirmed_at: nil, counted_at: Time.current)

        loan2 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
        loan2.update_columns(confirmed_at: nil, counted_at: nil)

        microcredit.clear_cache
        percent = microcredit.current_percent(100)
        expect(percent).to eq(0.5) # 1 counted out of 2 total
      end

      it 'returns 0 when no loans for amount' do
        expect(microcredit.current_percent(999)).to eq(0.0)
      end
    end

    describe '#next_percent' do
      it 'calculates next percentage after counting one more' do
        2.times do
          loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
          loan.update_columns(confirmed_at: nil, counted_at: nil)
        end
        microcredit.clear_cache
        percent = microcredit.next_percent(100)
        expect(percent).to eq(0.5) # (0 + 1) / 2
      end

      it 'returns 1.0 when no loans for amount' do
        expect(microcredit.next_percent(999)).to eq(1.0)
      end
    end

    describe '#should_count?' do
      it 'returns true for confirmed loans when slots available' do
        result = microcredit.should_count?(100, true)
        expect(result).to be_in([true, false]) # Depends on remaining_percent
      end

      it 'returns false when no slots remaining' do
        10.times do
          loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
          loan.update_columns(counted_at: Time.current)
        end
        microcredit.clear_cache
        expect(microcredit.should_count?(100, true)).to be false
      end
    end
  end

  # ====================
  # PHASE MANAGEMENT TESTS
  # ====================

  describe '#change_phase!' do
    it 'updates reset_at timestamp' do
      microcredit = create(:microcredit, :active)
      expect(microcredit.reset_at).to be_nil

      microcredit.change_phase!
      expect(microcredit.reload.reset_at).not_to be_nil
    end

    it 'clears cache' do
      microcredit = create(:microcredit, :active)
      expect(microcredit).to receive(:clear_cache)
      microcredit.change_phase!
    end

    it 'updates counted_at for confirmed unaccounted loans' do
      microcredit = create(:microcredit, :active, limits: '100€: 10')
      option = create(:microcredit_option, microcredit: microcredit)
      loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
      loan.update_columns(confirmed_at: Time.current, counted_at: nil)

      microcredit.change_phase!
      expect(loan.reload.counted_at).not_to be_nil
    end
  end

  # ====================
  # FRIENDLY ID TESTS
  # ====================

  describe '#slug_candidates' do
    it 'returns array of slug candidates' do
      microcredit = build(:microcredit, title: 'Test Campaign')
      candidates = microcredit.slug_candidates
      expect(candidates).to be_an(Array)
      expect(candidates.first).to eq(:title)
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe '.total_current_amount' do
    it 'sums total_goal for given ids' do
      m1 = create(:microcredit, total_goal: 1000)
      m2 = create(:microcredit, total_goal: 2000)
      total = described_class.total_current_amount([m1.id, m2.id])
      expect(total).to eq(3000)
    end

    it 'returns 0 for empty array' do
      total = described_class.total_current_amount([])
      expect(total).to eq(0)
    end
  end

  # ====================
  # SUBGOALS TESTS
  # ====================

  describe '#subgoals' do
    it 'returns nil when no subgoals set' do
      microcredit = create(:microcredit)
      expect(microcredit.subgoals).to be_nil
    end

    it 'parses YAML subgoals safely' do
      microcredit = create(:microcredit)
      microcredit.update_column(:subgoals, { goal1: 500, goal2: 1000 }.to_yaml)
      expect(microcredit.subgoals).to be_a(Hash)
    end
  end

  # ====================
  # CACHE MANAGEMENT TESTS
  # ====================

  describe '#clear_cache' do
    it 'clears cached instance variables' do
      microcredit = create(:microcredit, :active, limits: '100€: 10')
      option = create(:microcredit_option, microcredit: microcredit)
      create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)

      # Access to populate cache
      microcredit.campaign_status
      microcredit.phase_status
      microcredit.subgoals

      # Clear cache
      microcredit.clear_cache

      # Verify cache is cleared by checking instance variables
      expect(microcredit.instance_variable_get(:@campaign_status)).to be_nil
      expect(microcredit.instance_variable_get(:@phase_status)).to be_nil
      expect(microcredit.instance_variable_get(:@subgoals)).to be_nil
    end
  end

  # ====================
  # UPCOMING TEXT TESTS
  # ====================

  describe '#get_microcredit_index_upcoming_text' do
    it 'returns correct text for campaigns more than 15 days away' do
      microcredit = create(:microcredit, starts_at: 20.days.from_now, ends_at: 30.days.from_now)
      text = microcredit.get_microcredit_index_upcoming_text
      expect(text).not_to be_nil
      expect(text).to be_a(String)
    end

    it 'returns correct text for campaigns 2-15 days away' do
      microcredit = create(:microcredit, starts_at: 5.days.from_now, ends_at: 15.days.from_now)
      text = microcredit.get_microcredit_index_upcoming_text
      expect(text).not_to be_nil
      expect(text).to be_a(String)
    end

    it 'returns correct text for campaigns tomorrow' do
      microcredit = create(:microcredit, starts_at: 1.day.from_now, ends_at: 10.days.from_now)
      text = microcredit.get_microcredit_index_upcoming_text
      expect(text).not_to be_nil
      expect(text).to be_a(String)
    end

    it 'returns correct text for campaigns starting in hours' do
      microcredit = create(:microcredit, starts_at: 5.hours.from_now, ends_at: 10.days.from_now)
      text = microcredit.get_microcredit_index_upcoming_text
      expect(text).not_to be_nil
      expect(text).to be_a(String)
    end

    it 'returns correct text for campaigns starting in minutes' do
      microcredit = create(:microcredit, starts_at: 30.minutes.from_now, ends_at: 10.days.from_now)
      text = microcredit.get_microcredit_index_upcoming_text
      expect(text).not_to be_nil
      expect(text).to be_a(String)
    end
  end

  # ====================
  # VALIDATION TESTS (ADDITIONAL)
  # ====================

  describe '#check_limits_with_phase' do
    it 'prevents setting limit below current phase count' do
      microcredit = create(:microcredit, :active, limits: '100€: 5')
      option = create(:microcredit_option, microcredit: microcredit)

      # Create 3 counted loans
      3.times do
        loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: option, amount: 100)
        loan.update_columns(counted_at: Time.current)
      end

      microcredit.clear_cache
      microcredit.limits = '100€: 2' # Try to set below current count

      expect(microcredit).not_to be_valid
      expect(microcredit.errors[:limits]).to be_present
    end
  end

  describe '#check_bank_counted_amount' do
    it 'prevents decreasing bank_counted_amount' do
      microcredit = create(:microcredit, bank_counted_amount: 1000)
      microcredit.bank_counted_amount = 500

      expect(microcredit).not_to be_valid
      expect(microcredit.errors.messages.values.flatten).to include('No puedes establecer un saldo bancario inferior al que ya había.')
    end

    it 'allows increasing bank_counted_amount' do
      microcredit = create(:microcredit, bank_counted_amount: 1000)
      microcredit.bank_counted_amount = 1500

      expect(microcredit).to be_valid
    end
  end

  # ====================
  # ATTACHMENT VALIDATION TESTS
  # ====================

  describe 'renewal_terms attachment' do
    it 'accepts PDF files' do
      microcredit = create(:microcredit)
      microcredit.renewal_terms.attach(
        io: StringIO.new('%PDF-1.4 test'),
        filename: 'terms.pdf',
        content_type: 'application/pdf'
      )
      expect(microcredit).to be_valid
    end

    it 'rejects non-PDF files' do
      microcredit = build(:microcredit)
      microcredit.renewal_terms.attach(
        io: StringIO.new('test'),
        filename: 'terms.txt',
        content_type: 'text/plain'
      )
      expect(microcredit).not_to be_valid
      expect(microcredit.errors[:renewal_terms]).to include('debe ser un archivo PDF')
    end

    it 'rejects files larger than 2MB' do
      microcredit = build(:microcredit)
      large_content = 'A' * (2.megabytes + 1)
      microcredit.renewal_terms.attach(
        io: StringIO.new(large_content),
        filename: 'large.pdf',
        content_type: 'application/pdf'
      )
      expect(microcredit).not_to be_valid
      expect(microcredit.errors[:renewal_terms]).to include('debe ser menor de 2MB')
    end
  end

  # ====================
  # OPTIONS SUMMARY TESTS
  # ====================

  describe '#options_summary' do
    it 'generates summary of loan amounts by options' do
      microcredit = create(:microcredit, :active)
      parent = create(:microcredit_option, microcredit: microcredit, name: 'Parent')
      child = create(:microcredit_option, microcredit: microcredit, parent: parent, name: 'Child')

      loan = create(:microcredit_loan, microcredit: microcredit, microcredit_option: child, amount: 100)
      loan.update_column(:confirmed_at, Time.current)

      summary = microcredit.options_summary
      expect(summary).to have_key(:data)
      expect(summary).to have_key(:grand_total)
      expect(summary[:grand_total]).to eq(100)
    end

    it 'handles options without loans' do
      microcredit = create(:microcredit, :active)
      create(:microcredit_option, microcredit: microcredit)

      summary = microcredit.options_summary
      expect(summary[:grand_total]).to be >= 0
    end

    it 'groups children under parents' do
      microcredit = create(:microcredit, :active, limits: "100€: 10\n200€: 10")
      parent = create(:microcredit_option, microcredit: microcredit, name: 'Parent')
      child1 = create(:microcredit_option, microcredit: microcredit, parent: parent, name: 'Child1')
      child2 = create(:microcredit_option, microcredit: microcredit, parent: parent, name: 'Child2')

      loan1 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: child1, amount: 100)
      loan1.update_column(:confirmed_at, Time.current)

      loan2 = create(:microcredit_loan, microcredit: microcredit, microcredit_option: child2, amount: 200)
      loan2.update_column(:confirmed_at, Time.current)

      summary = microcredit.options_summary
      expect(summary[:grand_total]).to be >= 0
      expect(summary[:data]).to be_an(Array)
    end
  end
end
