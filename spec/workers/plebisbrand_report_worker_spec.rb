# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisBrandReportWorker, type: :worker do
  describe 'Sidekiq configuration' do
    it 'is configured with the correct queue' do
      expect(described_class.sidekiq_options['queue']).to eq(:plebisbrand_report_queue)
    end

    it 'includes Sidekiq::Worker' do
      expect(described_class.ancestors).to include(Sidekiq::Worker)
    end
  end

  describe '#perform' do
    let(:worker) { described_class.new }
    let(:report) { create(:report) }

    before do
      # Create a test report with minimal valid data
      report.query = 'SELECT * FROM users LIMIT 10'
      report.save(validate: false)
    end

    it 'finds the report by id' do
      expect(Report).to receive(:find).with(report.id).and_return(report)
      allow(report).to receive(:run!)

      worker.perform(report.id)
    end

    it 'calls run! on the report' do
      expect(report).to receive(:run!)

      worker.perform(report.id)
    end

    it 'processes report successfully' do
      allow(report).to receive(:run!)

      expect { worker.perform(report.id) }.not_to raise_error
    end

    context 'with valid report' do
      before do
        allow(report).to receive(:run!).and_call_original
        # Create some test users for the report to process
        create_list(:user, 3)
      end

      it 'executes the report' do
        expect { worker.perform(report.id) }.not_to raise_error
      end

      it 'updates report results' do
        initial_results = report.results

        worker.perform(report.id)

        report.reload
        expect(report.results).not_to eq(initial_results)
      end
    end

    context 'error handling' do
      context 'when report not found' do
        it 'raises RecordNotFound error' do
          expect { worker.perform(999_999) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when report_id is nil' do
        it 'raises RecordNotFound error' do
          expect { worker.perform(nil) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when report.run! fails' do
        before do
          allow(report).to receive(:run!).and_raise(StandardError.new('Report execution failed'))
        end

        it 'propagates the error' do
          expect { worker.perform(report.id) }.to raise_error(StandardError, 'Report execution failed')
        end
      end

      context 'when report query is invalid' do
        before do
          report.query = 'INVALID SQL QUERY'
          report.save(validate: false)
        end

        it 'raises an error' do
          expect { worker.perform(report.id) }.to raise_error
        end
      end

      context 'when report query references non-existent table' do
        before do
          report.query = 'SELECT * FROM non_existent_table'
          report.save(validate: false)
        end

        it 'raises an error' do
          expect { worker.perform(report.id) }.to raise_error
        end
      end
    end

    context 'with different report configurations' do
      before do
        create_list(:user, 5)
      end

      context 'with main_group' do
        before do
          report.query = 'SELECT * FROM users LIMIT 10'
          report.main_group = { field: 'email', width: 50 }.to_yaml
          report.save(validate: false)
          allow(report).to receive(:run!).and_call_original
        end

        it 'processes report with main_group' do
          expect { worker.perform(report.id) }.not_to raise_error
        end
      end

      context 'with groups' do
        before do
          report.query = 'SELECT * FROM users LIMIT 10'
          report.groups = [{ field: 'document_type', width: 10 }].to_yaml
          report.save(validate: false)
          allow(report).to receive(:run!).and_call_original
        end

        it 'processes report with groups' do
          expect { worker.perform(report.id) }.not_to raise_error
        end
      end

      context 'with version_at timestamp' do
        before do
          report.query = 'SELECT * FROM users LIMIT 10'
          report.version_at = 1.day.ago
          report.save(validate: false)
          allow(report).to receive(:run!).and_call_original
        end

        it 'processes report with version_at' do
          expect { worker.perform(report.id) }.not_to raise_error
        end
      end
    end

    context 'report file operations' do
      let(:report_folder) { Rails.root.join("tmp/report/#{report.id}").to_s }
      let(:raw_folder) { "#{report_folder}/raw" }
      let(:rank_folder) { "#{report_folder}/rank" }

      before do
        create_list(:user, 3)
        report.query = 'SELECT * FROM users LIMIT 10'
        report.save(validate: false)
      end

      after do
        # Clean up test files
        FileUtils.rm_rf(report_folder) if File.exist?(report_folder)
      end

      it 'creates report folders' do
        worker.perform(report.id)

        expect(File.directory?(report_folder)).to be true
      end

      it 'creates raw data folder' do
        worker.perform(report.id)

        expect(File.directory?(raw_folder)).to be true
      end

      it 'creates rank folder' do
        worker.perform(report.id)

        expect(File.directory?(rank_folder)).to be true
      end
    end

    context 'integration scenarios' do
      before do
        create_list(:user, 10)
      end

      it 'processes small dataset' do
        report.query = 'SELECT * FROM users LIMIT 5'
        report.save(validate: false)

        expect { worker.perform(report.id) }.not_to raise_error
      end

      it 'processes larger dataset' do
        report.query = 'SELECT * FROM users LIMIT 100'
        report.save(validate: false)

        expect { worker.perform(report.id) }.not_to raise_error
      end

      it 'handles report with no results' do
        report.query = 'SELECT * FROM users WHERE id = -1'
        report.save(validate: false)

        expect { worker.perform(report.id) }.not_to raise_error
      end

      it 'saves report results' do
        report.query = 'SELECT * FROM users LIMIT 10'
        report.save(validate: false)

        worker.perform(report.id)

        report.reload
        expect(report.results).not_to be_nil
      end
    end

    context 'batch processing' do
      before do
        create_list(:user, 50)
        report.query = 'SELECT * FROM users'
        report.save(validate: false)
      end

      it 'processes report in batches' do
        expect { worker.perform(report.id) }.not_to raise_error
      end

      it 'completes processing all records' do
        worker.perform(report.id)

        report.reload
        expect(report.results).not_to be_nil
      end
    end

    context 'Sidekiq retry behavior' do
      it 'can be retried on failure' do
        # First call fails
        allow(Report).to receive(:find).with(report.id).and_raise(StandardError.new('Temporary failure'))

        expect { worker.perform(report.id) }.to raise_error(StandardError)

        # Second call succeeds
        allow(Report).to receive(:find).with(report.id).and_call_original
        allow(report).to receive(:run!)

        expect { worker.perform(report.id) }.not_to raise_error
      end
    end

    context 'concurrent execution' do
      let(:report2) { create(:report) }

      before do
        [report, report2].each do |r|
          r.query = 'SELECT * FROM users LIMIT 10'
          r.save(validate: false)
        end
        create_list(:user, 5)
      end

      it 'processes multiple reports independently' do
        expect { worker.perform(report.id) }.not_to raise_error
        expect { worker.perform(report2.id) }.not_to raise_error
      end

      it 'creates separate folders for each report' do
        worker.perform(report.id)
        worker.perform(report2.id)

        folder1 = Rails.root.join("tmp/report/#{report.id}").to_s
        folder2 = Rails.root.join("tmp/report/#{report2.id}").to_s

        expect(File.directory?(folder1)).to be true
        expect(File.directory?(folder2)).to be true

        # Clean up
        FileUtils.rm_rf(folder1) if File.exist?(folder1)
        FileUtils.rm_rf(folder2) if File.exist?(folder2)
      end
    end

    context 'security considerations' do
      context 'with SQL injection attempt' do
        before do
          # Note: Report model already has security measures in place
          # We're testing that malicious queries are handled appropriately
          report.query = "SELECT * FROM users WHERE id = 1; DROP TABLE users; --"
          report.save(validate: false)
        end

        it 'raises an error for malicious query' do
          expect { worker.perform(report.id) }.to raise_error
        end
      end

      context 'with path traversal attempt in report id' do
        it 'raises error for non-numeric id' do
          expect { worker.perform('../../../etc/passwd') }.to raise_error
        end
      end
    end

    context 'memory management' do
      before do
        # Create many records to test memory handling
        create_list(:user, 100)
        report.query = 'SELECT * FROM users'
        report.save(validate: false)
      end

      it 'processes large datasets without memory issues' do
        expect { worker.perform(report.id) }.not_to raise_error
      end
    end

    context 'edge cases' do
      context 'with empty query' do
        before do
          report.query = ''
          report.save(validate: false)
        end

        it 'raises an error' do
          expect { worker.perform(report.id) }.to raise_error
        end
      end

      context 'with whitespace-only query' do
        before do
          report.query = '   '
          report.save(validate: false)
        end

        it 'raises an error' do
          expect { worker.perform(report.id) }.to raise_error
        end
      end

      context 'with complex query' do
        before do
          create_list(:user, 10)
          report.query = 'SELECT id, email, created_at FROM users WHERE created_at > NOW() - INTERVAL \'1 year\' ORDER BY created_at DESC'
          report.save(validate: false)
        end

        it 'processes complex query successfully' do
          expect { worker.perform(report.id) }.not_to raise_error
        end
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

  describe 'performance characteristics' do
    let(:worker) { described_class.new }
    let(:report) { create(:report) }

    before do
      create_list(:user, 20)
      report.query = 'SELECT * FROM users'
      report.save(validate: false)
    end

    it 'completes within reasonable time' do
      start_time = Time.current

      worker.perform(report.id)

      elapsed_time = Time.current - start_time
      expect(elapsed_time).to be < 30 # Should complete within 30 seconds
    end

    it 'can process multiple reports sequentially' do
      report2 = create(:report)
      report2.query = 'SELECT * FROM users LIMIT 10'
      report2.save(validate: false)

      expect do
        worker.perform(report.id)
        worker.perform(report2.id)
      end.not_to raise_error
    end
  end
end
