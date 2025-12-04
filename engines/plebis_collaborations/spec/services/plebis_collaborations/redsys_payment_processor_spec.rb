# frozen_string_literal: true

require 'rails_helper'

module PlebisCollaborations
  RSpec.describe RedsysPaymentProcessor, type: :service do
    let(:order_parent) { double('OrderParent') }
    let(:order) { double('Order', first: true, is_payable?: true, redsys_parse_response!: true) }
    let(:redsys_order_id) { 'TEST123' }

    before do
      allow(PlebisCollaborations::Order).to receive(:parent_from_order_id)
        .with(redsys_order_id).and_return(order_parent)
      allow(order_parent).to receive(:create_order).and_return(order)
    end

    describe '#initialize' do
      it 'stores request params and body' do
        processor = described_class.new({ 'key' => 'value' }, '<xml>body</xml>')
        expect(processor.instance_variable_get(:@request_params)).to eq({ 'key' => 'value' })
        expect(processor.instance_variable_get(:@request_body)).to eq('<xml>body</xml>')
      end

      it 'handles nil request body' do
        processor = described_class.new({ 'key' => 'value' })
        expect(processor.instance_variable_get(:@request_body)).to be_nil
      end
    end

    describe '#process' do
      context 'with standard HTTP POST callback' do
        let(:request_params) do
          {
            'Ds_Order' => redsys_order_id,
            'Ds_Amount' => '1000',
            'Ds_Response' => '0000',
            'Ds_MerchantCode' => '999008881',
            'Ds_Signature' => 'test_signature'
          }
        end

        it 'processes standard callback successfully' do
          processor = described_class.new(request_params)
          result = processor.process

          expect(result[:order]).to eq(order)
          expect(result[:is_soap]).to be false
          expect(result[:raw_xml]).to be_nil
          expect(result[:parsed_params]).to eq(request_params)
        end

        it 'finds and creates order' do
          processor = described_class.new(request_params)
          expect(PlebisCollaborations::Order).to receive(:parent_from_order_id)
            .with(redsys_order_id)
          expect(order_parent).to receive(:create_order).with(kind_of(Time), true)

          processor.process
        end

        it 'parses response if order is payable' do
          processor = described_class.new(request_params)
          expect(order).to receive(:redsys_parse_response!).with(request_params, nil)

          processor.process
        end

        it 'does not parse response if order is not first' do
          allow(order).to receive(:first).and_return(false)
          processor = described_class.new(request_params)
          expect(order).not_to receive(:redsys_parse_response!)

          processor.process
        end

        it 'does not parse response if order is not payable' do
          allow(order).to receive(:is_payable?).and_return(false)
          processor = described_class.new(request_params)
          expect(order).not_to receive(:redsys_parse_response!)

          processor.process
        end
      end

      context 'with SOAP/XML callback' do
        let(:soap_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <Envelope>
              <Body>
                <procesaNotificacionSIS>
                  <XML><![CDATA[
                    <Message>
                      <Request>
                        <Ds_Order>#{redsys_order_id}</Ds_Order>
                        <Ds_Amount>1000</Ds_Amount>
                        <Ds_Response>0000</Ds_Response>
                        <Ds_MerchantCode>999008881</Ds_MerchantCode>
                      </Request>
                      <Signature>soap_signature</Signature>
                    </Message>
                  ]]></XML>
                </procesaNotificacionSIS>
              </Body>
            </Envelope>
          XML
        end

        it 'processes SOAP callback with blank params' do
          processor = described_class.new({}, soap_body)
          result = processor.process

          expect(result[:order]).to eq(order)
          expect(result[:is_soap]).to be true
          expect(result[:raw_xml]).to include('<Message>')
          expect(result[:parsed_params]['Ds_Order']).to eq(redsys_order_id)
          expect(result[:parsed_params]['Ds_Signature']).to eq('soap_signature')
        end

        it 'processes SOAP callback with missing Ds_Order in params' do
          processor = described_class.new({ 'other_param' => 'value' }, soap_body)
          result = processor.process

          expect(result[:is_soap]).to be true
          expect(result[:parsed_params]['Ds_Order']).to eq(redsys_order_id)
        end

        it 'extracts all fields from SOAP XML' do
          processor = described_class.new({}, soap_body)
          result = processor.process

          parsed = result[:parsed_params]
          expect(parsed['Ds_Order']).to eq(redsys_order_id)
          expect(parsed['Ds_Amount']).to eq('1000')
          expect(parsed['Ds_Response']).to eq('0000')
          expect(parsed['Ds_MerchantCode']).to eq('999008881')
          expect(parsed['Ds_Signature']).to eq('soap_signature')
        end

        it 'stores raw XML for processing' do
          processor = described_class.new({}, soap_body)
          result = processor.process

          expect(result[:raw_xml]).to be_present
          expect(result[:raw_xml]).to include('<Message>')
          expect(result[:raw_xml]).to include('<Request>')
        end

        it 'parses response with raw XML when order is payable' do
          processor = described_class.new({}, soap_body)
          expect(order).to receive(:redsys_parse_response!)
            .with(hash_including('Ds_Order' => redsys_order_id), kind_of(String))

          processor.process
        end
      end

      context 'error handling' do
        it 'handles invalid XML gracefully' do
          invalid_xml = '<invalid>xml'
          expect do
            described_class.new({}, invalid_xml).process
          end.to raise_error(REXML::ParseException).or raise_error(Nokogiri::XML::SyntaxError)
        end

        it 'handles missing order parent' do
          allow(PlebisCollaborations::Order).to receive(:parent_from_order_id)
            .and_raise(ActiveRecord::RecordNotFound)

          processor = described_class.new({ 'Ds_Order' => 'INVALID' })
          expect do
            processor.process
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe '#is_soap_callback?' do
      it 'returns true for blank params' do
        processor = described_class.new({})
        expect(processor.send(:is_soap_callback?)).to be true
      end

      it 'returns true for params without Ds_Order' do
        processor = described_class.new({ 'other' => 'value' })
        expect(processor.send(:is_soap_callback?)).to be true
      end

      it 'returns false for params with Ds_Order' do
        processor = described_class.new({ 'Ds_Order' => 'TEST123' })
        expect(processor.send(:is_soap_callback?)).to be false
      end
    end

    describe '#parse_callback' do
      it 'returns params directly for standard callback' do
        params = { 'Ds_Order' => 'TEST123' }
        processor = described_class.new(params)
        expect(processor.send(:parse_callback)).to eq(params)
      end

      it 'parses SOAP XML for SOAP callback' do
        soap_body = <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <Envelope>
            <Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>TEST123</Ds_Order>
                    </Request>
                    <Signature>sig123</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </Body>
          </Envelope>
        XML

        processor = described_class.new({}, soap_body)
        result = processor.send(:parse_callback)

        expect(result['Ds_Order']).to eq('TEST123')
        expect(result['Ds_Signature']).to eq('sig123')
      end
    end

    describe '#parse_soap_callback' do
      let(:soap_body) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <Envelope>
            <Body>
              <procesaNotificacionSIS>
                <XML><![CDATA[
                  <Message>
                    <Request>
                      <Ds_Order>ORDER123</Ds_Order>
                      <Ds_Amount>5000</Ds_Amount>
                    </Request>
                    <Signature>signature_value</Signature>
                  </Message>
                ]]></XML>
              </procesaNotificacionSIS>
            </Body>
          </Envelope>
        XML
      end

      it 'extracts request parameters from XML' do
        processor = described_class.new({}, soap_body)
        result = processor.send(:parse_soap_callback)

        expect(result['Ds_Order']).to eq('ORDER123')
        expect(result['Ds_Amount']).to eq('5000')
      end

      it 'extracts signature from XML' do
        processor = described_class.new({}, soap_body)
        result = processor.send(:parse_soap_callback)

        expect(result['Ds_Signature']).to eq('signature_value')
      end

      it 'merges with existing request params' do
        processor = described_class.new({ 'extra_param' => 'extra_value' }, soap_body)
        result = processor.send(:parse_soap_callback)

        expect(result['Ds_Order']).to eq('ORDER123')
        expect(result['extra_param']).to eq('extra_value')
      end

      it 'stores raw XML' do
        processor = described_class.new({}, soap_body)
        processor.send(:parse_soap_callback)

        raw_xml = processor.instance_variable_get(:@raw_xml)
        expect(raw_xml).to include('<Message>')
        expect(raw_xml).to include('ORDER123')
      end
    end

    describe '#find_and_create_order' do
      let(:parsed_params) { { 'Ds_Order' => redsys_order_id } }

      it 'finds parent from order ID' do
        processor = described_class.new({})
        expect(PlebisCollaborations::Order).to receive(:parent_from_order_id)
          .with(redsys_order_id)
          .and_return(order_parent)

        processor.send(:find_and_create_order, parsed_params)
      end

      it 'creates order with timestamp and payment flag' do
        processor = described_class.new({})
        expect(order_parent).to receive(:create_order)
          .with(kind_of(Time), true)
          .and_return(order)

        processor.send(:find_and_create_order, parsed_params)
      end

      it 'parses response when order is valid' do
        processor = described_class.new({})
        processor.instance_variable_set(:@raw_xml, '<xml>test</xml>')

        expect(order).to receive(:redsys_parse_response!)
          .with(parsed_params, '<xml>test</xml>')

        processor.send(:find_and_create_order, parsed_params)
      end

      it 'returns created order' do
        processor = described_class.new({})
        result = processor.send(:find_and_create_order, parsed_params)

        expect(result).to eq(order)
      end
    end

    describe 'integration scenarios' do
      context 'complete payment flow' do
        let(:collaboration) { double('Collaboration', id: 1) }
        let(:order_parent) { double('OrderParent', id: 1, collaboration: collaboration) }

        it 'processes successful payment with standard callback' do
          params = {
            'Ds_Order' => 'ORD001',
            'Ds_Response' => '0000',
            'Ds_Amount' => '10000',
            'Ds_Signature' => 'valid_sig'
          }

          allow(PlebisCollaborations::Order).to receive(:parent_from_order_id)
            .and_return(order_parent)
          allow(order_parent).to receive(:create_order).and_return(order)

          processor = described_class.new(params)
          result = processor.process

          expect(result[:order]).to be_present
          expect(result[:is_soap]).to be false
          expect(result[:parsed_params]['Ds_Response']).to eq('0000')
        end

        it 'processes failed payment' do
          failed_order = double('Order', first: true, is_payable?: true)
          params = {
            'Ds_Order' => 'ORD002',
            'Ds_Response' => '0101',
            'Ds_Amount' => '10000'
          }

          allow(PlebisCollaborations::Order).to receive(:parent_from_order_id)
            .and_return(order_parent)
          allow(order_parent).to receive(:create_order).and_return(failed_order)
          allow(failed_order).to receive(:redsys_parse_response!)

          processor = described_class.new(params)
          result = processor.process

          expect(result[:order]).to eq(failed_order)
          expect(result[:parsed_params]['Ds_Response']).to eq('0101')
        end
      end
    end
  end
end
