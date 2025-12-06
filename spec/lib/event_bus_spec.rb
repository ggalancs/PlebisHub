# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/event_bus'

RSpec.describe EventBus do
  let(:instance) { described_class.instance }

  after do
    instance.clear!
  end

  describe '.instance' do
    it 'returns a singleton instance' do
      expect(described_class.instance).to be_a(described_class)
      expect(described_class.instance).to eq(described_class.instance)
    end
  end

  describe '#publish' do
    it 'creates an Event object' do
      event = instance.publish('test.event', { key: 'value' })
      expect(event).to be_an(EventBus::Event)
    end

    it 'executes synchronous subscribers' do
      called = false
      instance.subscribe('test.event') { |_event| called = true }
      instance.publish('test.event', {})
      expect(called).to be true
    end

    it 'passes event to subscribers' do
      received_event = nil
      instance.subscribe('test.event') { |event| received_event = event }
      instance.publish('test.event', { data: 'test' })
      expect(received_event.payload[:data]).to eq('test')
    end

    it 'logs event publishing' do
      allow(Rails.logger).to receive(:info).and_call_original
      instance.publish('test.event', {})
      expect(Rails.logger).to have_received(:info).with(/Publishing: test.event/).at_least(:once)
    end

    it 'handles subscriber errors gracefully' do
      allow(Rails.logger).to receive(:error).and_call_original
      instance.subscribe('test.event') { |_e| raise StandardError, 'Test error' }
      expect { instance.publish('test.event', {}) }.not_to raise_error
      expect(Rails.logger).to have_received(:error).at_least(:once)
    end
  end

  describe '#subscribe' do
    it 'adds subscriber to the list' do
      instance.subscribe('test.event') { |_e| }
      expect(instance.instance_variable_get(:@subscribers)['test.event']).not_to be_empty
    end

    it 'accepts a callable' do
      callable = ->(event) { event.name }
      expect { instance.subscribe('test.event', callable) }.not_to raise_error
    end

    it 'accepts a block' do
      expect { instance.subscribe('test.event') { |_e| } }.not_to raise_error
    end

    it 'raises error if subscriber is not callable' do
      expect {
        instance.subscribe('test.event', 'not callable')
      }.to raise_error(ArgumentError, /must respond to #call/)
    end

    it 'logs subscription' do
      allow(Rails.logger).to receive(:info).and_call_original
      instance.subscribe('test.event') { |_e| }
      expect(Rails.logger).to have_received(:info).with(/Subscribed to: test.event/).at_least(:once)
    end
  end

  describe '#subscribe_async' do
    let(:listener_class) do
      Class.new do
        def self.call(_event); end
      end
    end

    it 'adds async subscriber' do
      instance.subscribe_async('test.event', listener_class)
      expect(instance.instance_variable_get(:@async_subscribers)['test.event']).to include(listener_class)
    end

    it 'raises error if listener does not respond to call' do
      expect {
        instance.subscribe_async('test.event', String)
      }.to raise_error(ArgumentError, /must respond to .call/)
    end

    it 'logs async subscription' do
      allow(Rails.logger).to receive(:info).and_call_original
      instance.subscribe_async('test.event', listener_class)
      expect(Rails.logger).to have_received(:info).with(/Async subscribed to: test.event/).at_least(:once)
    end
  end

  describe '#clear!' do
    it 'clears all subscribers' do
      instance.subscribe('test1') { |_e| }
      instance.subscribe('test2') { |_e| }
      instance.clear!
      expect(instance.instance_variable_get(:@subscribers)).to be_empty
      expect(instance.instance_variable_get(:@async_subscribers)).to be_empty
    end
  end

  describe EventBus::Event do
    let(:event) { EventBus::Event.new('test.event', { key: 'value' }) }

    it 'has a name' do
      expect(event.name).to eq('test.event')
    end

    it 'has a payload' do
      expect(event.payload).to eq({ key: 'value' })
    end

    it 'has an id' do
      expect(event.id).to be_a(String)
    end

    it 'has occurred_at timestamp' do
      expect(event.occurred_at).to be_a(Time)
    end

    it 'symbolizes payload keys' do
      event = EventBus::Event.new('test', { 'string_key' => 'value' })
      expect(event.payload).to have_key(:string_key)
    end

    describe '#to_h' do
      it 'returns hash representation' do
        hash = event.to_h
        expect(hash).to have_key(:id)
        expect(hash).to have_key(:name)
        expect(hash).to have_key(:payload)
        expect(hash).to have_key(:occurred_at)
      end

      it 'formats occurred_at as ISO8601' do
        hash = event.to_h
        expect(hash[:occurred_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      end
    end

    describe '#[]' do
      it 'accesses payload values' do
        expect(event[:key]).to eq('value')
      end

      it 'symbolizes string keys' do
        expect(event['key']).to eq('value')
      end
    end
  end

  describe PlebisConfig do
    describe '.event_persistence_enabled?' do
      it 'returns true in production' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        expect(PlebisConfig.event_persistence_enabled?).to be true
      end

      it 'returns true when ENV variable is set' do
        allow(ENV).to receive(:[]).with('EVENT_PERSISTENCE').and_return('true')
        expect(PlebisConfig.event_persistence_enabled?).to be true
      end

      it 'returns false in development by default' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        allow(ENV).to receive(:[]).with('EVENT_PERSISTENCE').and_return(nil)
        expect(PlebisConfig.event_persistence_enabled?).to be false
      end
    end
  end

  describe EventBusWorker do
    let(:listener_class) do
      Class.new do
        def self.call(_event); end
      end
    end

    before do
      stub_const('TestListener', listener_class)
    end

    it 'performs listener class call' do
      worker = described_class.new
      event_hash = { 'name' => 'test.event', 'payload' => { 'key' => 'value' } }
      expect(TestListener).to receive(:call)
      worker.perform('TestListener', event_hash)
    end

    it 'reconstructs Event from hash' do
      worker = described_class.new
      event_hash = { 'name' => 'test.event', 'payload' => { 'key' => 'value' } }
      allow(TestListener).to receive(:call) do |event|
        expect(event).to be_an(EventBus::Event)
        expect(event.name).to eq('test.event')
      end
      worker.perform('TestListener', event_hash)
    end

    it 'logs errors' do
      worker = described_class.new
      event_hash = { 'name' => 'test', 'payload' => {} }
      allow(TestListener).to receive(:call).and_raise(StandardError, 'Test error')
      allow(Rails.logger).to receive(:error).and_call_original
      expect { worker.perform('TestListener', event_hash) }.to raise_error(StandardError)
      expect(Rails.logger).to have_received(:error).at_least(:once)
    end
  end

  describe 'helper methods' do
    describe 'publish_event' do
      it 'delegates to EventBus.instance.publish' do
        expect(instance).to receive(:publish).with('test.event', { data: 'test' })
        publish_event('test.event', { data: 'test' })
      end
    end

    describe 'subscribe_to_event' do
      it 'delegates to EventBus.instance.subscribe' do
        block = proc { |_e| }
        expect(instance).to receive(:subscribe).with('test.event')
        subscribe_to_event('test.event', &block)
      end
    end
  end
end
