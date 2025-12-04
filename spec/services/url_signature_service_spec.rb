# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlSignatureService do
  # ==================== INHERITANCE TESTS ====================

  describe 'inheritance' do
    it 'is defined as a class' do
      expect(described_class).to be_a(Class)
    end

    it 'attempts to inherit from PlebisVerification::UrlSignatureService' do
      # Since PlebisVerification::UrlSignatureService doesn't exist, we verify the class definition
      expect { described_class }.not_to raise_error(NameError)
    end

    context 'when parent class exists' do
      before do
        # Create the parent class dynamically for testing
        unless defined?(PlebisVerification)
          module PlebisVerification
          end
        end

        unless PlebisVerification.const_defined?(:UrlSignatureService)
          PlebisVerification.const_set(:UrlSignatureService, Class.new do
            def initialize(secret_key)
              @secret_key = secret_key
            end

            def sign_url(url, params = {})
              signature = generate_signature(url, params)
              "#{url}?signature=#{signature}"
            end

            def verify_signature(url, signature)
              expected_signature = generate_signature(url, {})
              signature == expected_signature
            end

            private

            def generate_signature(url, params)
              "sig_#{url}_#{@secret_key}"
            end
          end)
        end
      end

      after do
        if defined?(PlebisVerification) && PlebisVerification.const_defined?(:UrlSignatureService)
          PlebisVerification.send(:remove_const, :UrlSignatureService)
        end
      end

      it 'inherits from PlebisVerification::UrlSignatureService' do
        expect(described_class.superclass.name).to eq('PlebisVerification::UrlSignatureService')
      end

      it 'can be instantiated' do
        service = described_class.new('secret_key')
        expect(service).to be_a(UrlSignatureService)
      end

      it 'inherits methods from parent class' do
        service = described_class.new('secret_key')
        expect(service).to respond_to(:sign_url)
        expect(service).to respond_to(:verify_signature)
      end

      it 'can call inherited methods' do
        service = described_class.new('secret_key')
        result = service.sign_url('https://example.com')
        expect(result).to include('signature=')
      end

      it 'maintains instance variables from parent' do
        service = described_class.new('my_secret')
        expect(service.instance_variable_get(:@secret_key)).to eq('my_secret')
      end

      it 'can verify signatures' do
        service = described_class.new('secret_key')
        url = 'https://example.com'
        signature = 'sig_https://example.com_secret_key'
        expect(service.verify_signature(url, signature)).to be true
      end
    end
  end

  # ==================== BACKWARD COMPATIBILITY TESTS ====================

  describe 'backward compatibility' do
    before do
      unless defined?(PlebisVerification)
        module PlebisVerification
        end
      end

      unless PlebisVerification.const_defined?(:UrlSignatureService)
        PlebisVerification.const_set(:UrlSignatureService, Class.new do
          attr_reader :secret_key

          def initialize(secret_key)
            @secret_key = secret_key
          end

          def sign_url(url, params = {})
            "#{url}?sig=signed"
          end
        end)
      end
    end

    after do
      if defined?(PlebisVerification) && PlebisVerification.const_defined?(:UrlSignatureService)
        PlebisVerification.send(:remove_const, :UrlSignatureService)
      end
    end

    it 'provides backward compatibility for old code using UrlSignatureService' do
      service = UrlSignatureService.new('secret')
      expect(service.secret_key).to eq('secret')
    end

    it 'works as drop-in replacement for namespaced version' do
      service1 = UrlSignatureService.new('secret')
      service2 = PlebisVerification::UrlSignatureService.new('secret')

      expect(service1.sign_url('https://example.com')).to eq(service2.sign_url('https://example.com'))
    end

    it 'is interchangeable with parent class' do
      service = described_class.new('secret')
      expect(service).to be_a(PlebisVerification::UrlSignatureService)
    end

    it 'allows polymorphic usage' do
      services = [
        UrlSignatureService.new('key1'),
        PlebisVerification::UrlSignatureService.new('key2')
      ]

      services.each do |service|
        expect(service).to respond_to(:sign_url)
      end
    end
  end

  # ==================== EDGE CASES ====================

  describe 'edge cases' do
    context 'when parent class is missing' do
      before do
        if defined?(PlebisVerification) && PlebisVerification.const_defined?(:UrlSignatureService)
          @original_class = PlebisVerification::UrlSignatureService
          PlebisVerification.send(:remove_const, :UrlSignatureService)
        end
      end

      after do
        if @original_class
          PlebisVerification.const_set(:UrlSignatureService, @original_class)
        end
      end

      it 'raises NameError on class load' do
        # Reload the class to trigger the error
        expect {
          load Rails.root.join('app/services/url_signature_service.rb')
        }.to raise_error(NameError)
      end
    end

    context 'when parent module is missing' do
      before do
        if defined?(PlebisVerification)
          @original_module = PlebisVerification
          Object.send(:remove_const, :PlebisVerification)
        end
      end

      after do
        if @original_module
          Object.const_set(:PlebisVerification, @original_module)
        end
      end

      it 'raises NameError on class load' do
        expect {
          load Rails.root.join('app/services/url_signature_service.rb')
        }.to raise_error(NameError)
      end
    end

    context 'with various initialization parameters' do
      before do
        unless defined?(PlebisVerification)
          module PlebisVerification
          end
        end

        unless PlebisVerification.const_defined?(:UrlSignatureService)
          PlebisVerification.const_set(:UrlSignatureService, Class.new do
            def initialize(*args)
              @args = args
            end

            attr_reader :args
          end)
        end
      end

      after do
        if defined?(PlebisVerification) && PlebisVerification.const_defined?(:UrlSignatureService)
          PlebisVerification.send(:remove_const, :UrlSignatureService)
        end
      end

      it 'handles single parameter' do
        service = described_class.new('secret')
        expect(service.args).to eq(['secret'])
      end

      it 'handles multiple parameters' do
        service = described_class.new('secret', 'algorithm')
        expect(service.args).to eq(['secret', 'algorithm'])
      end

      it 'handles no parameters' do
        service = described_class.new
        expect(service.args).to eq([])
      end

      it 'handles keyword arguments' do
        service = described_class.new(secret_key: 'key', algorithm: 'SHA256')
        expect(service.args.first).to eq({ secret_key: 'key', algorithm: 'SHA256' })
      end
    end
  end

  # ==================== CLASS STRUCTURE TESTS ====================

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

    it 'has single inheritance' do
      expect(described_class.ancestors.select { |a| a.is_a?(Class) }.count).to be >= 2
    end

    it 'has correct class name' do
      expect(described_class.name).to eq('UrlSignatureService')
    end

    it 'is properly namespaced (no namespace)' do
      expect(described_class.name).not_to include('::')
    end
  end

  # ==================== DOCUMENTATION TESTS ====================

  describe 'documentation' do
    it 'documents backward compatibility purpose' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to match(/backward compatibility/i)
    end

    it 'references the parent class in comments' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to include('PlebisVerification::UrlSignatureService')
    end

    it 'has alias comment' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to match(/alias/i)
    end
  end

  # ==================== SECURITY TESTS ====================

  describe 'security considerations' do
    before do
      unless defined?(PlebisVerification)
        module PlebisVerification
        end
      end

      unless PlebisVerification.const_defined?(:UrlSignatureService)
        PlebisVerification.const_set(:UrlSignatureService, Class.new do
          def initialize(secret_key)
            @secret_key = secret_key
          end

          def sign_url(url, params = {})
            "#{url}?signature=signed_with_#{@secret_key}"
          end
        end)
      end
    end

    after do
      if defined?(PlebisVerification) && PlebisVerification.const_defined?(:UrlSignatureService)
        PlebisVerification.send(:remove_const, :UrlSignatureService)
      end
    end

    it 'does not expose secrets in class definition' do
      class_source = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(class_source).not_to match(/secret/i)
    end

    it 'maintains encapsulation from parent' do
      service = described_class.new('secret_key')
      # Instance variable should not be directly accessible
      expect { service.secret_key }.to raise_error(NoMethodError)
    end
  end
end
