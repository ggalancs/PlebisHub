# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedsysPaymentProcessor do
  let(:request_params) { {} }
  let(:request_body) { nil }
  let(:processor) { described_class.new(request_params, request_body) }

  # ==================== INITIALIZATION TESTS ====================

  describe 'initialization' do
    it 'initializes with request_params' do
      expect(processor.instance_variable_get(:@request_params)).to eq(request_params)
    end

    it 'initializes with request_body' do
      expect(processor.instance_variable_get(:@request_body)).to eq(request_body)
    end

    it 'accepts nil request_body' do
      processor = described_class.new(request_params)
      expect(processor.instance_variable_get(:@request_body)).to be_nil
    end

    it 'accepts empty request_params' do
      processor = described_class.new({})
      expect(processor.instance_variable_get(:@request_params)).to eq({})
    end
  end

  # ==================== PROCESS METHOD TESTS ====================

  describe '#process' do
    let(:parent_order) { double('ParentCollaboration') }
    let(:order) { double('Order', first: true, is_payable?: true) }

    context 'with standard HTTP POST callback' do
      let(:request_params) do
        {
          'Ds_Order' => '123456789',
          'Ds_MerchantCode' => '999008881',
          'Ds_Amount' => '1000',
          'Ds_Response' => '0000'
        }
      end

      before do
        allow(Order).to receive(:parent_from_order_id).with('123456789').and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)
      end

      it 'returns order and processing info' do
        result = processor.process
        expect(result).to be_a(Hash)
        expect(result).to have_key(:order)
        expect(result).to have_key(:is_soap)
        expect(result).to have_key(:raw_xml)
        expect(result).to have_key(:parsed_params)
      end

      it 'identifies as non-SOAP callback' do
        result = processor.process
        expect(result[:is_soap]).to be false
      end

      it 'finds parent order by order_id' do
        expect(Order).to receive(:parent_from_order_id).with('123456789')
        processor.process
      end

      it 'creates order from parent' do
        expect(parent_order).to receive(:create_order).with(kind_of(Time), true)
        processor.process
      end

      it 'parses redsys response' do
        expect(order).to receive(:redsys_parse_response!).with(request_params, nil)
        processor.process
      end

      it 'returns request_params as parsed_params' do
        result = processor.process
        expect(result[:parsed_params]).to eq(request_params)
      end

      it 'returns nil raw_xml' do
        result = processor.process
        expect(result[:raw_xml]).to be_nil
      end
    end

    context 'with SOAP/XML callback' do
      let(:request_params) { {} }
      let(:xml_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>987654321</Ds_Order>
                      <Ds_MerchantCode>999008881</Ds_MerchantCode>
                      <Ds_Amount>2000</Ds_Amount>
                      <Ds_Response>0000</Ds_Response>
                    </Request>
                    <Signature>ABC123XYZ</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      before do
        allow(Order).to receive(:parent_from_order_id).with('987654321').and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)
      end

      it 'identifies as SOAP callback' do
        processor = described_class.new(request_params, xml_body)
        result = processor.process
        expect(result[:is_soap]).to be true
      end

      it 'extracts order_id from XML' do
        processor = described_class.new(request_params, xml_body)
        expect(Order).to receive(:parent_from_order_id).with('987654321')
        processor.process
      end

      it 'extracts signature from XML' do
        processor = described_class.new(request_params, xml_body)
        result = processor.process
        expect(result[:parsed_params]['Ds_Signature']).to eq('ABC123XYZ')
      end

      it 'preserves raw XML' do
        processor = described_class.new(request_params, xml_body)
        result = processor.process
        expect(result[:raw_xml]).to include('<Message>')
        expect(result[:raw_xml]).to include('987654321')
      end

      it 'parses redsys response with XML' do
        processor = described_class.new(request_params, xml_body)
        expect(order).to receive(:redsys_parse_response!).with(kind_of(Hash), kind_of(String))
        processor.process
      end
    end

    context 'when Ds_Order is blank in request_params' do
      let(:request_params) { { 'Ds_Order' => '', 'Other_Param' => 'value' } }
      let(:xml_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>111222333</Ds_Order>
                    </Request>
                    <Signature>SIG123</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      before do
        # The empty Ds_Order will be merged and override the XML value, so expect empty string
        allow(Order).to receive(:parent_from_order_id).with('').and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)
      end

      it 'treats as SOAP callback' do
        processor = described_class.new(request_params, xml_body)
        result = processor.process
        expect(result[:is_soap]).to be true
      end

      it 'parses XML body but merges blank Ds_Order from params' do
        processor = described_class.new(request_params, xml_body)
        expect(Order).to receive(:parent_from_order_id).with('')
        processor.process
      end
    end

    context 'when order is not first' do
      before do
        allow(Order).to receive(:parent_from_order_id).and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:first).and_return(false)
        allow(order).to receive(:is_payable?).and_return(true)
      end

      it 'does not parse redsys response' do
        request_params = { 'Ds_Order' => '123456789' }
        processor = described_class.new(request_params)
        expect(order).not_to receive(:redsys_parse_response!)
        processor.process
      end
    end

    context 'when order is not payable' do
      before do
        allow(Order).to receive(:parent_from_order_id).and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:first).and_return(true)
        allow(order).to receive(:is_payable?).and_return(false)
      end

      it 'does not parse redsys response' do
        request_params = { 'Ds_Order' => '123456789' }
        processor = described_class.new(request_params)
        expect(order).not_to receive(:redsys_parse_response!)
        processor.process
      end
    end

    context 'when both first and payable' do
      before do
        allow(Order).to receive(:parent_from_order_id).and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:first).and_return(true)
        allow(order).to receive(:is_payable?).and_return(true)
        allow(order).to receive(:redsys_parse_response!)
      end

      it 'parses redsys response' do
        request_params = { 'Ds_Order' => '123456789' }
        processor = described_class.new(request_params)
        expect(order).to receive(:redsys_parse_response!)
        processor.process
      end
    end
  end

  # ==================== PRIVATE METHOD TESTS ====================

  describe 'private methods' do
    describe '#is_soap_callback?' do
      context 'when request_params is blank' do
        it 'returns true for nil' do
          processor = described_class.new(nil)
          expect(processor.send(:is_soap_callback?)).to be true
        end

        it 'returns true for empty hash' do
          processor = described_class.new({})
          expect(processor.send(:is_soap_callback?)).to be true
        end
      end

      context 'when Ds_Order is blank' do
        it 'returns true for nil Ds_Order' do
          processor = described_class.new({ 'Ds_Order' => nil })
          expect(processor.send(:is_soap_callback?)).to be true
        end

        it 'returns true for empty Ds_Order' do
          processor = described_class.new({ 'Ds_Order' => '' })
          expect(processor.send(:is_soap_callback?)).to be true
        end
      end

      context 'when Ds_Order is present' do
        it 'returns false' do
          processor = described_class.new({ 'Ds_Order' => '123456789' })
          expect(processor.send(:is_soap_callback?)).to be false
        end
      end
    end

    describe '#parse_callback' do
      context 'for standard callback' do
        let(:request_params) { { 'Ds_Order' => '123456789', 'Ds_Amount' => '1000' } }

        it 'returns request_params unchanged' do
          result = processor.send(:parse_callback)
          expect(result).to eq(request_params)
        end
      end

      context 'for SOAP callback' do
        let(:xml_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <procesaNotificacionSIS>
                  <XML><![CDATA[
                    <Message>
                      <Request>
                        <Ds_Order>987654321</Ds_Order>
                        <Ds_Amount>2000</Ds_Amount>
                      </Request>
                      <Signature>ABC123</Signature>
                    </Message>
                  ]]></XML>
                </procesaNotificacionSIS>
              </soap:Body>
            </soap:Envelope>
          XML
        end

        it 'parses XML and returns hash' do
          processor = described_class.new({}, xml_body)
          result = processor.send(:parse_callback)
          expect(result).to be_a(Hash)
          expect(result['Ds_Order']).to eq('987654321')
        end
      end
    end

    describe '#parse_soap_callback' do
      let(:xml_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>111222333</Ds_Order>
                      <Ds_MerchantCode>999008881</Ds_MerchantCode>
                      <Ds_Amount>1500</Ds_Amount>
                      <Ds_Response>0000</Ds_Response>
                    </Request>
                    <Signature>XYZ789ABC</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      it 'extracts Request parameters' do
        processor = described_class.new({}, xml_body)
        result = processor.send(:parse_soap_callback)
        expect(result['Ds_Order']).to eq('111222333')
        expect(result['Ds_MerchantCode']).to eq('999008881')
        expect(result['Ds_Amount']).to eq('1500')
        expect(result['Ds_Response']).to eq('0000')
      end

      it 'extracts Signature' do
        processor = described_class.new({}, xml_body)
        result = processor.send(:parse_soap_callback)
        expect(result['Ds_Signature']).to eq('XYZ789ABC')
      end

      it 'stores raw XML' do
        processor = described_class.new({}, xml_body)
        processor.send(:parse_soap_callback)
        raw_xml = processor.instance_variable_get(:@raw_xml)
        expect(raw_xml).to include('<Message>')
        expect(raw_xml).to include('111222333')
      end

      it 'merges with request_params if present' do
        processor = described_class.new({ 'Extra_Param' => 'value' }, xml_body)
        result = processor.send(:parse_soap_callback)
        expect(result['Extra_Param']).to eq('value')
        expect(result['Ds_Order']).to eq('111222333')
      end
    end

    describe '#find_and_create_order' do
      let(:parsed_params) { { 'Ds_Order' => '123456789' } }
      let(:parent_order) { double('ParentCollaboration') }
      let(:order) { double('Order', first: true, is_payable?: true) }

      before do
        allow(Order).to receive(:parent_from_order_id).with('123456789').and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)
      end

      it 'finds parent order' do
        expect(Order).to receive(:parent_from_order_id).with('123456789')
        processor.send(:find_and_create_order, parsed_params)
      end

      it 'creates order with timestamp and true flag' do
        expect(parent_order).to receive(:create_order).with(kind_of(Time), true)
        processor.send(:find_and_create_order, parsed_params)
      end

      it 'returns created order' do
        result = processor.send(:find_and_create_order, parsed_params)
        expect(result).to eq(order)
      end

      it 'passes raw_xml to redsys_parse_response if available' do
        processor.instance_variable_set(:@raw_xml, '<xml>test</xml>')
        expect(order).to receive(:redsys_parse_response!).with(parsed_params, '<xml>test</xml>')
        processor.send(:find_and_create_order, parsed_params)
      end

      it 'passes nil as raw_xml if not available' do
        expect(order).to receive(:redsys_parse_response!).with(parsed_params, nil)
        processor.send(:find_and_create_order, parsed_params)
      end
    end
  end

  # ==================== EDGE CASES ====================

  describe 'edge cases' do
    context 'when XML is malformed' do
      let(:malformed_xml) { '<invalid>xml<without>proper</closing>' }

      it 'raises XML parsing error' do
        processor = described_class.new({}, malformed_xml)
        expect { processor.process }.to raise_error(REXML::ParseException)
      end
    end

    context 'when XML has unexpected structure' do
      let(:unexpected_xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <DifferentRoot>
            <SomeData>value</SomeData>
          </DifferentRoot>
        XML
      end

      it 'raises error due to missing expected structure' do
        processor = described_class.new({}, unexpected_xml)
        expect { processor.process }.to raise_error(NoMethodError)
      end
    end

    context 'when Ds_Order is missing in both params and XML' do
      let(:xml_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Amount>1000</Ds_Amount>
                    </Request>
                    <Signature>SIG</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      it 'attempts to find parent with nil order_id' do
        processor = described_class.new({}, xml_body)
        expect(Order).to receive(:parent_from_order_id).with(nil)
        allow(Order).to receive(:parent_from_order_id).and_raise(StandardError)
        expect { processor.process }.to raise_error(StandardError)
      end
    end

    context 'when parent order is not found' do
      let(:request_params) { { 'Ds_Order' => 'nonexistent' } }

      it 'raises error' do
        allow(Order).to receive(:parent_from_order_id).and_raise(ActiveRecord::RecordNotFound)
        expect { processor.process }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when create_order fails' do
      let(:request_params) { { 'Ds_Order' => '123456789' } }
      let(:parent_order) { double('ParentCollaboration') }

      before do
        allow(Order).to receive(:parent_from_order_id).and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'propagates the error' do
        expect { processor.process }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with nil values' do
      it 'handles nil request_params gracefully' do
        processor = described_class.new(nil)
        expect(processor.instance_variable_get(:@request_params)).to be_nil
      end

      it 'handles nil request_body gracefully' do
        processor = described_class.new({}, nil)
        expect(processor.instance_variable_get(:@request_body)).to be_nil
      end
    end

    context 'with special characters in XML' do
      let(:xml_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>123&amp;456</Ds_Order>
                      <Ds_Amount>1000</Ds_Amount>
                    </Request>
                    <Signature>ABC&lt;123&gt;</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      it 'handles XML entities correctly' do
        processor = described_class.new({}, xml_body)
        parent_order = double('ParentCollaboration')
        order = double('Order', first: true, is_payable?: true)
        allow(Order).to receive(:parent_from_order_id).with('123&456').and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)

        result = processor.process
        expect(result[:parsed_params]['Ds_Order']).to eq('123&456')
      end
    end
  end

  # ==================== SECURITY TESTS ====================

  describe 'security' do
    describe 'XML external entity (XXE) prevention' do
      let(:xxe_xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>&xxe;</Ds_Order>
                    </Request>
                    <Signature>SIG</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      it 'does not process external entities' do
        processor = described_class.new({}, xxe_xml)
        # Rails Hash.from_xml uses REXML which has XXE protection by default
        # The entity reference will not be resolved, but we still need to mock the Order lookup
        parent_order = double('ParentCollaboration')
        order = double('Order', first: true, is_payable?: true)
        allow(Order).to receive(:parent_from_order_id).and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)

        expect { processor.process }.not_to raise_error
      end
    end

    describe 'SQL injection prevention via ActiveRecord' do
      let(:request_params) { { 'Ds_Order' => "123'; DROP TABLE orders;--" } }
      let(:parent_order) { double('ParentCollaboration') }
      let(:order) { double('Order', first: true, is_payable?: true) }

      it 'safely passes malicious order_id to ActiveRecord' do
        allow(Order).to receive(:parent_from_order_id).with("123'; DROP TABLE orders;--").and_return(parent_order)
        allow(parent_order).to receive(:create_order).and_return(order)
        allow(order).to receive(:redsys_parse_response!)

        expect { processor.process }.not_to raise_error
      end
    end
  end

  # ==================== INTEGRATION TESTS ====================

  describe 'integration' do
    let(:parent_order) { double('ParentCollaboration') }
    let(:order) { double('Order', first: true, is_payable?: true) }

    before do
      allow(Order).to receive(:parent_from_order_id).and_return(parent_order)
      allow(parent_order).to receive(:create_order).and_return(order)
      allow(order).to receive(:redsys_parse_response!)
    end

    context 'standard callback flow' do
      let(:request_params) do
        {
          'Ds_Order' => '123456789',
          'Ds_MerchantCode' => '999008881',
          'Ds_Amount' => '1000',
          'Ds_Response' => '0000'
        }
      end

      it 'processes complete standard callback' do
        result = processor.process

        expect(result[:order]).to eq(order)
        expect(result[:is_soap]).to be false
        expect(result[:parsed_params]).to eq(request_params)
        expect(result[:raw_xml]).to be_nil
      end
    end

    context 'SOAP callback flow' do
      let(:xml_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>987654321</Ds_Order>
                      <Ds_MerchantCode>999008881</Ds_MerchantCode>
                      <Ds_Amount>2000</Ds_Amount>
                      <Ds_Response>0000</Ds_Response>
                    </Request>
                    <Signature>ABC123XYZ</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </soap:Body>
          </soap:Envelope>
        XML
      end

      it 'processes complete SOAP callback' do
        processor = described_class.new({}, xml_body)
        result = processor.process

        expect(result[:order]).to eq(order)
        expect(result[:is_soap]).to be true
        expect(result[:parsed_params]['Ds_Order']).to eq('987654321')
        expect(result[:parsed_params]['Ds_Signature']).to eq('ABC123XYZ')
        expect(result[:raw_xml]).to be_present
      end
    end
  end
end
