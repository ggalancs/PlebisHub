# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisBrandCollaborationWorker, type: :worker do
  describe 'Sidekiq configuration' do
    it 'is configured with the correct queue' do
      expect(described_class.sidekiq_options['queue']).to eq(:plebisbrand_collaboration_queue)
    end

    it 'includes Sidekiq::Worker' do
      expect(described_class.ancestors).to include(Sidekiq::Worker)
    end
  end

  describe '#perform' do
    let(:worker) { described_class.new }

    context 'with special collaboration_id -1' do
      let(:collaboration_id) { -1 }
      let(:today) { Time.zone.today }
      let(:folder) { File.dirname(Collaboration.bank_filename(today, true)) }
      let(:filename) { Collaboration.bank_filename(today, false) }

      before do
        # Clean up any existing files/folders before each test
        FileUtils.rm_rf(folder) if File.exist?(folder)
      end

      after do
        # Clean up after tests
        FileUtils.rm_rf(folder) if File.exist?(folder)
      end

      it 'generates bank export file for today' do
        # Create test collaboration with order
        collab = create(:collaboration, :active, :with_iban)
        order = create(:order, parent: collab, user: collab.user,
                      payment_type: 3, payable_at: today)

        allow(Collaboration).to receive(:bank_filename)
          .with(today, true).and_return("#{Rails.root}/tmp/test_bank_file.csv")
        allow(Collaboration).to receive(:bank_filename)
          .with(today, false).and_return('test_bank_file')

        allow(Collaboration).to receive(:bank_file_lock)

        # Mock export_data to avoid actual file creation
        expect(worker).to receive(:export_data).and_yield(collab)

        # Mock the collaboration method
        allow(collab).to receive(:skip_queries_validations=)
        allow(collab).to receive(:get_bank_data).with(today)

        worker.perform(collaboration_id)
      end

      it 'filters out credit card payments' do
        # Create credit card collaboration (should be excluded)
        credit_card_collab = create(:collaboration, :active, payment_type: 1)
        create(:order, parent: credit_card_collab, user: credit_card_collab.user,
               payment_type: 1, payable_at: today)

        # Create bank transfer collaboration (should be included)
        bank_collab = create(:collaboration, :active, :with_iban)
        bank_order = create(:order, parent: bank_collab, user: bank_collab.user,
                            payment_type: 3, payable_at: today)

        allow(Collaboration).to receive(:bank_filename).and_return("#{Rails.root}/tmp/test.csv")
        allow(Collaboration).to receive(:bank_file_lock)

        expect(worker).to receive(:export_data) do |filename, query, options|
          # Verify query excludes payment_type 1
          results = query.to_a
          expect(results.map(&:payment_type)).not_to include(1)
          expect(results.map(&:id)).to include(bank_collab.id)
        end.and_yield(bank_collab)

        allow(bank_collab).to receive(:skip_queries_validations=)
        allow(bank_collab).to receive(:get_bank_data)

        worker.perform(collaboration_id)
      end

      it 'includes orders for today' do
        collab = create(:collaboration, :active, :with_iban)
        order_today = create(:order, parent: collab, user: collab.user,
                            payable_at: today)

        allow(Collaboration).to receive(:bank_filename).and_return("#{Rails.root}/tmp/test.csv")
        allow(Collaboration).to receive(:bank_file_lock)

        expect(worker).to receive(:export_data) do |filename, query, options|
          results = query.to_a
          expect(results.count).to be > 0
        end.and_yield(collab)

        allow(collab).to receive(:skip_queries_validations=)
        allow(collab).to receive(:get_bank_data)

        worker.perform(collaboration_id)
      end

      it 'sets skip_queries_validations on each collaboration' do
        collab = create(:collaboration, :active, :with_iban)
        create(:order, parent: collab, user: collab.user, payable_at: today)

        allow(Collaboration).to receive(:bank_filename).and_return("#{Rails.root}/tmp/test.csv")
        allow(Collaboration).to receive(:bank_file_lock)

        expect(worker).to receive(:export_data).and_yield(collab)
        expect(collab).to receive(:skip_queries_validations=).with(true)
        allow(collab).to receive(:get_bank_data).with(today)

        worker.perform(collaboration_id)
      end

      it 'calls get_bank_data with today date' do
        collab = create(:collaboration, :active, :with_iban)
        create(:order, parent: collab, user: collab.user, payable_at: today)

        allow(Collaboration).to receive(:bank_filename).and_return("#{Rails.root}/tmp/test.csv")
        allow(Collaboration).to receive(:bank_file_lock)

        expect(worker).to receive(:export_data).and_yield(collab)
        allow(collab).to receive(:skip_queries_validations=)
        expect(collab).to receive(:get_bank_data).with(today)

        worker.perform(collaboration_id)
      end

      it 'unlocks bank file after export' do
        collab = create(:collaboration, :active, :with_iban)
        create(:order, parent: collab, user: collab.user, payable_at: today)

        allow(Collaboration).to receive(:bank_filename).and_return("#{Rails.root}/tmp/test.csv")
        allow(worker).to receive(:export_data)

        expect(Collaboration).to receive(:bank_file_lock).with(false)

        worker.perform(collaboration_id)
      end

      it 'uses correct folder from bank_filename' do
        expected_folder = File.dirname(Collaboration.bank_filename(today, true))

        allow(Collaboration).to receive(:bank_file_lock)
        allow(worker).to receive(:export_data) do |filename, query, options|
          expect(options[:folder]).to eq(expected_folder)
        end

        worker.perform(collaboration_id)
      end

      it 'uses comma as column separator' do
        allow(Collaboration).to receive(:bank_file_lock)
        allow(worker).to receive(:export_data) do |filename, query, options|
          expect(options[:col_sep]).to eq(',')
        end

        worker.perform(collaboration_id)
      end
    end

    context 'with specific collaboration_id' do
      let(:collaboration) { create(:collaboration, :unconfirmed, :with_iban) }

      it 'finds the collaboration by id' do
        expect(Collaboration).to receive(:find).with(collaboration.id).and_return(collaboration)
        allow(collaboration).to receive(:fix_status!).and_return(false)
        allow(collaboration).to receive(:charge!)

        worker.perform(collaboration.id)
      end

      it 'calls fix_status! on the collaboration' do
        expect(collaboration).to receive(:fix_status!).and_return(false)
        allow(collaboration).to receive(:charge!)

        worker.perform(collaboration.id)
      end

      it 'calls charge! when fix_status! returns false' do
        allow(collaboration).to receive(:fix_status!).and_return(false)
        expect(collaboration).to receive(:charge!)

        worker.perform(collaboration.id)
      end

      it 'does not call charge! when fix_status! returns true' do
        allow(collaboration).to receive(:fix_status!).and_return(true)
        expect(collaboration).not_to receive(:charge!)

        worker.perform(collaboration.id)
      end

      context 'when collaboration is active and chargeable' do
        let(:collaboration) { create(:collaboration, :active, :with_iban) }
        let(:order) { create(:order, parent: collaboration, user: collaboration.user, status: 0) }

        before do
          allow(collaboration).to receive(:fix_status!).and_return(false)
          allow(collaboration).to receive(:get_orders).and_return([[order]])
        end

        it 'processes the charge successfully' do
          expect { worker.perform(collaboration.id) }.not_to raise_error
        end
      end

      context 'when collaboration has errors' do
        let(:collaboration) { create(:collaboration, :error, :with_iban) }

        it 'fixes the status but does not charge' do
          allow(collaboration).to receive(:fix_status!).and_return(true)
          expect(collaboration).not_to receive(:charge!)

          worker.perform(collaboration.id)
        end
      end

      context 'when collaboration is incomplete' do
        let(:collaboration) { create(:collaboration, :incomplete, :with_iban) }

        it 'handles incomplete collaboration' do
          allow(collaboration).to receive(:fix_status!).and_return(false)
          allow(collaboration).to receive(:charge!)

          expect { worker.perform(collaboration.id) }.not_to raise_error
        end
      end
    end

    context 'error handling' do
      it 'raises error when collaboration not found' do
        expect { worker.perform(999_999) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'handles nil collaboration_id gracefully' do
        expect { worker.perform(nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context 'when bank export fails' do
        before do
          allow(Collaboration).to receive(:bank_filename).and_raise(StandardError.new('Export failed'))
        end

        it 'propagates the error' do
          expect { worker.perform(-1) }.to raise_error(StandardError, 'Export failed')
        end
      end

      context 'when charge! fails' do
        let(:collaboration) { create(:collaboration, :active, :with_iban) }

        before do
          allow(collaboration).to receive(:fix_status!).and_return(false)
          allow(collaboration).to receive(:charge!).and_raise(StandardError.new('Charge failed'))
        end

        it 'propagates the error' do
          expect { worker.perform(collaboration.id) }.to raise_error(StandardError, 'Charge failed')
        end
      end
    end

    context 'integration scenarios' do
      it 'processes multiple collaborations in bank export' do
        collab1 = create(:collaboration, :active, :with_iban)
        collab2 = create(:collaboration, :active, :with_iban)
        today = Time.zone.today

        create(:order, parent: collab1, user: collab1.user, payment_type: 3, payable_at: today)
        create(:order, parent: collab2, user: collab2.user, payment_type: 3, payable_at: today)

        allow(Collaboration).to receive(:bank_filename).and_return("#{Rails.root}/tmp/test.csv")
        allow(Collaboration).to receive(:bank_file_lock)

        processed_count = 0
        allow(worker).to receive(:export_data) do |filename, query, options, &block|
          query.find_each do |collab|
            block.call(collab)
            processed_count += 1
          end
        end

        allow_any_instance_of(Collaboration).to receive(:skip_queries_validations=)
        allow_any_instance_of(Collaboration).to receive(:get_bank_data)

        worker.perform(-1)

        expect(processed_count).to eq(2)
      end

      it 'processes credit card collaboration' do
        collaboration = create(:collaboration, :active, payment_type: 1)

        allow(collaboration).to receive(:fix_status!).and_return(false)
        allow(collaboration).to receive(:charge!)

        expect { worker.perform(collaboration.id) }.not_to raise_error
      end

      it 'processes bank transfer collaboration' do
        collaboration = create(:collaboration, :active, :with_iban)

        allow(collaboration).to receive(:fix_status!).and_return(false)
        allow(collaboration).to receive(:charge!)

        expect { worker.perform(collaboration.id) }.not_to raise_error
      end
    end

    context 'Sidekiq retry behavior' do
      it 'can be retried on failure' do
        collaboration = create(:collaboration, :active, :with_iban)

        # First call fails
        allow(Collaboration).to receive(:find).with(collaboration.id).and_raise(StandardError.new('Temporary failure'))

        expect { worker.perform(collaboration.id) }.to raise_error(StandardError)

        # Second call succeeds
        allow(Collaboration).to receive(:find).with(collaboration.id).and_call_original
        allow(collaboration).to receive(:fix_status!).and_return(false)
        allow(collaboration).to receive(:charge!)

        expect { worker.perform(collaboration.id) }.not_to raise_error
      end
    end
  end

  describe 'worker instantiation' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end

    it 'responds to perform' do
      expect(described_class.new).to respond_to(:perform)
    end
  end
end
