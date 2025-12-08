# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoanRenewalService do
  # This is a backward compatibility alias class that inherits from
  # PlebisMicrocredit::LoanRenewalService. The parent class is defined
  # in the plebis_microcredit engine.

  describe 'class definition' do
    it 'is defined as a class' do
      expect(described_class).to be_a(Class)
    end

    it 'has correct class name' do
      expect(described_class.name).to eq('LoanRenewalService')
    end

    it 'is properly namespaced (no namespace)' do
      expect(described_class.name).not_to include('::')
    end
  end

  describe 'class structure' do
    it 'is frozen string literal' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      expect(file_content).to start_with("# frozen_string_literal: true")
    end

    it 'has no methods defined in itself' do
      own_methods = described_class.instance_methods(false)
      expect(own_methods).to be_empty
    end

    it 'has proper comment explaining its purpose' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      expect(file_content).to include('Backward compatibility')
    end

    it 'declares inheritance from PlebisMicrocredit::LoanRenewalService' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      expect(file_content).to include('< PlebisMicrocredit::LoanRenewalService')
    end
  end

  describe 'documentation' do
    it 'documents backward compatibility purpose' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      expect(file_content).to match(/backward compatibility/i)
    end

    it 'references the parent class in comments' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      expect(file_content).to include('PlebisMicrocredit::LoanRenewalService')
    end

    it 'includes alias keyword in comment' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      expect(file_content).to match(/alias/i)
    end
  end

  describe 'minimal footprint' do
    it 'has minimal code' do
      file_content = File.read(Rails.root.join('app/services/loan_renewal_service.rb'))
      # The file should be very small - just the class definition
      line_count = file_content.lines.reject { |l| l.strip.empty? || l.strip.start_with?('#') }.count
      expect(line_count).to be <= 3
    end
  end

  # Test that the parent class exists when the microcredit engine is loaded
  describe 'engine integration', if: defined?(PlebisMicrocredit::LoanRenewalService) do
    it 'inherits from PlebisMicrocredit::LoanRenewalService' do
      expect(described_class.superclass).to eq(PlebisMicrocredit::LoanRenewalService)
    end

    it 'can be instantiated' do
      microcredit = double('Microcredit')
      params = {}
      service = described_class.new(microcredit, params)
      expect(service).to be_a(described_class)
    end

    it 'is a subclass of parent' do
      microcredit = double('Microcredit')
      params = {}
      service = described_class.new(microcredit, params)
      expect(service).to be_a(PlebisMicrocredit::LoanRenewalService)
    end
  end
end
