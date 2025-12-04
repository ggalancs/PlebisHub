# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../lib/plebis_core/event_bus'

RSpec.describe PlebisCore::EventBus do
  after do
    # Clean up subscriptions after each test
    ActiveSupport::Notifications.notifier.instance_variable_get(:@subscribers).clear
  end

  describe '.publish' do
    it 'publishes event with plebis prefix' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('plebis.test.event', { data: 'test' })
      described_class.publish('test.event', { data: 'test' })
    end

    it 'logs event publishing' do
      allow(ActiveSupport::Notifications).to receive(:instrument)
      expect(Rails.logger).to receive(:debug).with(/Publishing: plebis.test.event/)
      described_class.publish('test.event', { key: 'value' })
    end

    it 'handles empty payload' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('plebis.test', {})
      described_class.publish('test')
    end

    it 'accepts symbol event names' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('plebis.user.created', anything)
      described_class.publish(:user.created, {})
    end

    context 'when error occurs' do
      it 'logs error and re-raises' do
        allow(ActiveSupport::Notifications).to receive(:instrument).and_raise(StandardError.new('Test error'))
        expect(Rails.logger).to receive(:error).with(/Error publishing/)
        expect(Rails.logger).to receive(:error).with(anything)
        expect { described_class.publish('test', {}) }.to raise_error(StandardError)
      end
    end
  end

  describe '.subscribe' do
    it 'subscribes to event with plebis prefix' do
      block_called = false
      described_class.subscribe('test.event') do |_event|
        block_called = true
      end

      ActiveSupport::Notifications.instrument('plebis.test.event', {})
      expect(block_called).to be true
    end

    it 'logs subscription' do
      expect(Rails.logger).to receive(:info).with('[EventBus] Subscribed to: plebis.test.event')
      described_class.subscribe('test.event') { |_e| }
    end

    it 'passes event object to block' do
      received_event = nil
      described_class.subscribe('test.event') do |event|
        received_event = event
      end

      ActiveSupport::Notifications.instrument('plebis.test.event', { key: 'value' })
      expect(received_event).to be_a(ActiveSupport::Notifications::Event)
      expect(received_event.payload[:key]).to eq('value')
    end

    it 'handles multiple subscribers' do
      counter = 0
      described_class.subscribe('test.event') { |_e| counter += 1 }
      described_class.subscribe('test.event') { |_e| counter += 10 }

      ActiveSupport::Notifications.instrument('plebis.test.event', {})
      expect(counter).to eq(11)
    end

    context 'when subscriber raises error' do
      it 'logs error but does not re-raise' do
        described_class.subscribe('test.event') do |_e|
          raise StandardError, 'Subscriber error'
        end

        expect(Rails.logger).to receive(:error).with(/Error in subscriber/)
        expect(Rails.logger).to receive(:error).with(anything)
        expect { ActiveSupport::Notifications.instrument('plebis.test.event', {}) }.not_to raise_error
      end

      it 'continues executing other subscribers' do
        counter = 0
        described_class.subscribe('test.event') { |_e| raise StandardError }
        described_class.subscribe('test.event') { |_e| counter += 1 }

        allow(Rails.logger).to receive(:error)
        ActiveSupport::Notifications.instrument('plebis.test.event', {})
        expect(counter).to eq(1)
      end
    end
  end

  describe '.unsubscribe' do
    it 'unsubscribes from event' do
      block_called = false
      described_class.subscribe('test.event') { |_e| block_called = true }
      described_class.unsubscribe('test.event')

      ActiveSupport::Notifications.instrument('plebis.test.event', {})
      expect(block_called).to be false
    end

    it 'logs unsubscription' do
      described_class.subscribe('test.event') { |_e| }
      expect(Rails.logger).to receive(:info).with('[EventBus] Unsubscribed from: plebis.test.event')
      described_class.unsubscribe('test.event')
    end

    it 'accepts subscriber object' do
      subscriber = ActiveSupport::Notifications.subscribe('plebis.test') { |*_args| }
      expect(Rails.logger).to receive(:info)
      described_class.unsubscribe('test', subscriber)
    end
  end

  describe '.clear_all_subscriptions!' do
    it 'clears all plebis subscriptions' do
      described_class.subscribe('test.event1') { |_e| }
      described_class.subscribe('test.event2') { |_e| }

      expect(Rails.logger).to receive(:warn).with('[EventBus] Clearing all subscriptions')
      described_class.clear_all_subscriptions!
    end

    it 'logs warning' do
      expect(Rails.logger).to receive(:warn).with('[EventBus] Clearing all subscriptions')
      described_class.clear_all_subscriptions!
    end
  end

  describe 'integration scenarios' do
    it 'publishes and receives events end-to-end' do
      received_payload = nil
      described_class.subscribe('user.registered') do |event|
        received_payload = event.payload
      end

      described_class.publish('user.registered', { user_id: 123, email: 'test@example.com' })

      expect(received_payload[:user_id]).to eq(123)
      expect(received_payload[:email]).to eq('test@example.com')
    end

    it 'handles multiple events independently' do
      user_events = []
      order_events = []

      described_class.subscribe('user.created') { |e| user_events << e.payload }
      described_class.subscribe('order.placed') { |e| order_events << e.payload }

      described_class.publish('user.created', { id: 1 })
      described_class.publish('order.placed', { id: 100 })

      expect(user_events.length).to eq(1)
      expect(order_events.length).to eq(1)
      expect(user_events.first[:id]).to eq(1)
      expect(order_events.first[:id]).to eq(100)
    end

    it 'supports complex event data' do
      received_data = nil
      described_class.subscribe('complex.event') do |event|
        received_data = event.payload
      end

      complex_payload = {
        user: { id: 1, name: 'John' },
        items: [1, 2, 3],
        metadata: { timestamp: Time.current }
      }

      described_class.publish('complex.event', complex_payload)
      expect(received_data[:user][:name]).to eq('John')
      expect(received_data[:items]).to eq([1, 2, 3])
    end
  end

  describe 'error resilience' do
    it 'isolated subscriber errors do not affect event publishing' do
      success_count = 0

      described_class.subscribe('test.event') { |_e| raise 'Error 1' }
      described_class.subscribe('test.event') { |_e| success_count += 1 }
      described_class.subscribe('test.event') { |_e| raise 'Error 2' }
      described_class.subscribe('test.event') { |_e| success_count += 1 }

      allow(Rails.logger).to receive(:error)
      described_class.publish('test.event', {})

      expect(success_count).to eq(2)
    end
  end
end
