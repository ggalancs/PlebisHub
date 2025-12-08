# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlSignatureService do
  # This is a backward compatibility alias class that inherits from
  # PlebisVerification::UrlSignatureService. The parent class is defined
  # in the plebis_verification engine.

  describe 'class definition' do
    it 'is defined as a class' do
      expect(described_class).to be_a(Class)
    end

    it 'has correct class name' do
      expect(described_class.name).to eq('UrlSignatureService')
    end

    it 'is properly namespaced (no namespace)' do
      expect(described_class.name).not_to include('::')
    end
  end

  describe 'class structure' do
    it 'is frozen string literal' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to start_with("# frozen_string_literal: true")
    end

    it 'has no methods defined in itself' do
      own_methods = described_class.instance_methods(false)
      expect(own_methods).to be_empty
    end

    it 'has proper comment explaining its purpose' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to include('Backward compatibility')
    end

    it 'declares inheritance from PlebisVerification::UrlSignatureService' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to include('< PlebisVerification::UrlSignatureService')
    end
  end

  describe 'documentation' do
    it 'documents backward compatibility purpose' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to match(/backward compatibility/i)
    end

    it 'references the parent class in comments' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to include('PlebisVerification::UrlSignatureService')
    end

    it 'includes alias keyword in comment' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to match(/alias/i)
    end
  end

  describe 'security' do
    it 'does not expose secrets in class definition' do
      class_source = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(class_source).not_to match(/password|secret_key|api_key/i)
    end

    it 'has minimal code footprint' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      # The file should be very small - just the class definition
      line_count = file_content.lines.reject { |l| l.strip.empty? || l.strip.start_with?('#') }.count
      expect(line_count).to be <= 3
    end
  end

  # Test that the parent class exists when the verification engine is loaded
  describe 'engine integration', if: defined?(PlebisVerification::UrlSignatureService) do
    it 'inherits from PlebisVerification::UrlSignatureService' do
      expect(described_class.superclass).to eq(PlebisVerification::UrlSignatureService)
    end

    it 'can be instantiated' do
      service = described_class.new('secret_key')
      expect(service).to be_a(described_class)
    end

    it 'is a subclass of parent' do
      service = described_class.new('secret_key')
      expect(service).to be_a(PlebisVerification::UrlSignatureService)
    end
  end
end
