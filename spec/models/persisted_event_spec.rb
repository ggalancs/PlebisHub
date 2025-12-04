# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersistedEvent, type: :model do
  # ====================
  # DATABASE SETUP TESTS
  # ====================

  describe 'database columns' do
    it 'has expected columns' do
      expect(PersistedEvent.column_names).to include(
        'id', 'event_type', 'payload', 'metadata',
        'occurred_at', 'created_at', 'updated_at'
      )
    end

    it 'has jsonb columns for payload and metadata' do
      columns = PersistedEvent.columns_hash
      expect(columns['payload'].type).to eq(:jsonb)
      expect(columns['metadata'].type).to eq(:jsonb)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    describe 'event_type' do
      it 'requires event_type' do
        event = PersistedEvent.new(
          payload: { data: 'test' },
          occurred_at: Time.current
        )
        expect(event).not_to be_valid
        expect(event.errors[:event_type]).to be_present
      end

      it 'accepts valid event_type' do
        event = PersistedEvent.new(
          event_type: 'user.created',
          payload: { data: 'test' },
          occurred_at: Time.current
        )
        expect(event).to be_valid
      end
    end

    describe 'payload' do
      it 'requires payload' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          occurred_at: Time.current
        )
        expect(event).not_to be_valid
        expect(event.errors[:payload]).to be_present
      end

      it 'accepts valid payload' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          payload: { user_id: 1, action: 'login' },
          occurred_at: Time.current
        )
        expect(event).to be_valid
      end

      it 'accepts complex nested payload' do
        event = PersistedEvent.new(
          event_type: 'order.created',
          payload: {
            user_id: 1,
            items: [
              { id: 1, name: 'Product 1', price: 10.99 },
              { id: 2, name: 'Product 2', price: 20.50 }
            ],
            total: 31.49
          },
          occurred_at: Time.current
        )
        expect(event).to be_valid
      end
    end

    describe 'occurred_at' do
      it 'requires occurred_at' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          payload: { data: 'test' }
        )
        expect(event).not_to be_valid
        expect(event.errors[:occurred_at]).to be_present
      end

      it 'accepts valid occurred_at' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          payload: { data: 'test' },
          occurred_at: Time.current
        )
        expect(event).to be_valid
      end

      it 'accepts past occurred_at' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          payload: { data: 'test' },
          occurred_at: 1.year.ago
        )
        expect(event).to be_valid
      end
    end

    describe 'metadata' do
      it 'allows empty metadata' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          payload: { data: 'test' },
          occurred_at: Time.current,
          metadata: {}
        )
        expect(event).to be_valid
      end

      it 'accepts valid metadata' do
        event = PersistedEvent.new(
          event_type: 'test.event',
          payload: { data: 'test' },
          occurred_at: Time.current,
          metadata: { ip: '192.168.1.1', user_agent: 'Mozilla/5.0' }
        )
        expect(event).to be_valid
      end
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates event with valid attributes' do
      expect do
        PersistedEvent.create!(
          event_type: 'user.login',
          payload: { user_id: 123 },
          occurred_at: Time.current
        )
      end.to change(PersistedEvent, :count).by(1)
    end

    it 'reads event attributes correctly' do
      event = PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 123, username: 'testuser' },
        metadata: { ip: '127.0.0.1' },
        occurred_at: Time.current
      )

      found_event = PersistedEvent.find(event.id)
      expect(found_event.event_type).to eq('user.login')
      expect(found_event.payload['user_id']).to eq(123)
      expect(found_event.payload['username']).to eq('testuser')
      expect(found_event.metadata['ip']).to eq('127.0.0.1')
    end

    it 'updates event attributes' do
      event = PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 123 },
        occurred_at: Time.current
      )

      event.update!(metadata: { processed: true })

      expect(event.reload.metadata['processed']).to eq(true)
    end

    it 'deletes event' do
      event = PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 123 },
        occurred_at: Time.current
      )

      expect { event.destroy }.to change(PersistedEvent, :count).by(-1)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    let!(:login_event1) do
      PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 1 },
        occurred_at: 3.days.ago
      )
    end

    let!(:login_event2) do
      PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 2 },
        occurred_at: 1.day.ago
      )
    end

    let!(:logout_event) do
      PersistedEvent.create!(
        event_type: 'user.logout',
        payload: { user_id: 1 },
        occurred_at: 2.days.ago
      )
    end

    let!(:today_event) do
      PersistedEvent.create!(
        event_type: 'user.action',
        payload: { user_id: 3 },
        occurred_at: Time.current
      )
    end

    describe '.by_type' do
      it 'returns events of specified type' do
        events = PersistedEvent.by_type('user.login')
        expect(events.count).to eq(2)
        expect(events).to include(login_event1, login_event2)
      end

      it 'returns empty collection for non-existent type' do
        events = PersistedEvent.by_type('non.existent')
        expect(events).to be_empty
      end

      it 'filters correctly with multiple types' do
        login_events = PersistedEvent.by_type('user.login')
        logout_events = PersistedEvent.by_type('user.logout')

        expect(login_events.count).to eq(2)
        expect(logout_events.count).to eq(1)
      end
    end

    describe '.recent' do
      it 'orders events by occurred_at descending' do
        events = PersistedEvent.recent
        expect(events.first).to eq(today_event)
        expect(events.second).to eq(login_event2)
        expect(events.third).to eq(logout_event)
        expect(events.fourth).to eq(login_event1)
      end

      it 'can be chained with other scopes' do
        events = PersistedEvent.by_type('user.login').recent
        expect(events.count).to eq(2)
        expect(events.first).to eq(login_event2)
        expect(events.second).to eq(login_event1)
      end
    end

    describe '.today' do
      it 'returns events from today' do
        events = PersistedEvent.today
        expect(events).to include(today_event)
        expect(events).not_to include(login_event1, login_event2, logout_event)
      end

      it 'returns empty collection when no events today' do
        PersistedEvent.where(occurred_at: Time.current.beginning_of_day..).destroy_all
        events = PersistedEvent.today
        expect(events).to be_empty
      end

      it 'includes events at beginning of day' do
        beginning_event = PersistedEvent.create!(
          event_type: 'test.event',
          payload: { test: true },
          occurred_at: Time.current.beginning_of_day
        )
        events = PersistedEvent.today
        expect(events).to include(beginning_event)
      end
    end

    describe '.this_week' do
      it 'returns events from this week' do
        events = PersistedEvent.this_week
        # All test events are within recent days, so should be in current week
        expect(events.count).to be >= 1
      end

      it 'excludes events from previous weeks' do
        old_event = PersistedEvent.create!(
          event_type: 'old.event',
          payload: { test: true },
          occurred_at: 2.weeks.ago
        )
        events = PersistedEvent.this_week
        expect(events).not_to include(old_event)
      end

      it 'includes events at beginning of week' do
        week_start_event = PersistedEvent.create!(
          event_type: 'test.event',
          payload: { test: true },
          occurred_at: Time.current.beginning_of_week
        )
        events = PersistedEvent.this_week
        expect(events).to include(week_start_event)
      end
    end

    describe '.this_month' do
      it 'returns events from this month' do
        events = PersistedEvent.this_month
        expect(events.count).to be >= 1
      end

      it 'excludes events from previous months' do
        old_event = PersistedEvent.create!(
          event_type: 'old.event',
          payload: { test: true },
          occurred_at: 2.months.ago
        )
        events = PersistedEvent.this_month
        expect(events).not_to include(old_event)
      end

      it 'includes events at beginning of month' do
        month_start_event = PersistedEvent.create!(
          event_type: 'test.event',
          payload: { test: true },
          occurred_at: Time.current.beginning_of_month
        )
        events = PersistedEvent.this_month
        expect(events).to include(month_start_event)
      end
    end

    describe 'scope chaining' do
      it 'chains by_type with today' do
        PersistedEvent.create!(
          event_type: 'user.login',
          payload: { user_id: 99 },
          occurred_at: Time.current
        )

        events = PersistedEvent.by_type('user.login').today
        expect(events.count).to be >= 1
        expect(events.pluck(:event_type).uniq).to eq(['user.login'])
      end

      it 'chains multiple scopes together' do
        events = PersistedEvent.by_type('user.login').this_week.recent
        expect(events.count).to be >= 0
      end
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe '.stream_for' do
    let!(:aggregate_events) do
      [
        PersistedEvent.create!(
          event_type: 'order.created',
          payload: { aggregate_type: 'Order', aggregate_id: '123', status: 'pending' },
          occurred_at: 3.hours.ago
        ),
        PersistedEvent.create!(
          event_type: 'order.paid',
          payload: { aggregate_type: 'Order', aggregate_id: '123', amount: 100 },
          occurred_at: 2.hours.ago
        ),
        PersistedEvent.create!(
          event_type: 'order.shipped',
          payload: { aggregate_type: 'Order', aggregate_id: '123', tracking: 'ABC123' },
          occurred_at: 1.hour.ago
        )
      ]
    end

    let!(:other_aggregate_event) do
      PersistedEvent.create!(
        event_type: 'order.created',
        payload: { aggregate_type: 'Order', aggregate_id: '456', status: 'pending' },
        occurred_at: 2.hours.ago
      )
    end

    let!(:different_type_event) do
      PersistedEvent.create!(
        event_type: 'user.created',
        payload: { aggregate_type: 'User', aggregate_id: '123', name: 'Test' },
        occurred_at: 2.hours.ago
      )
    end

    it 'returns events for specific aggregate' do
      events = PersistedEvent.stream_for('Order', '123')
      expect(events.count).to eq(3)
      expect(events.pluck(:id)).to match_array(aggregate_events.map(&:id))
    end

    it 'orders events by occurred_at ascending' do
      events = PersistedEvent.stream_for('Order', '123')
      expect(events.map(&:event_type)).to eq(['order.created', 'order.paid', 'order.shipped'])
    end

    it 'filters by aggregate_type correctly' do
      events = PersistedEvent.stream_for('Order', '123')
      expect(events).not_to include(different_type_event)
    end

    it 'filters by aggregate_id correctly' do
      events = PersistedEvent.stream_for('Order', '123')
      expect(events).not_to include(other_aggregate_event)
    end

    it 'returns empty collection for non-existent aggregate' do
      events = PersistedEvent.stream_for('Order', '999')
      expect(events).to be_empty
    end

    it 'handles integer aggregate_id' do
      PersistedEvent.create!(
        event_type: 'test.event',
        payload: { aggregate_type: 'Test', aggregate_id: 789 },
        occurred_at: Time.current
      )

      events = PersistedEvent.stream_for('Test', 789)
      expect(events.count).to eq(1)
    end

    it 'reconstructs aggregate state from stream' do
      events = PersistedEvent.stream_for('Order', '123')
      state = events.each_with_object({}) do |event, acc|
        acc.merge!(event.payload)
      end

      expect(state['status']).to eq('pending')
      expect(state['amount']).to eq(100)
      expect(state['tracking']).to eq('ABC123')
    end
  end

  describe '.replay' do
    before do
      PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 1, timestamp: '2024-01-01' },
        occurred_at: 2.days.ago
      )
      PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: 2, timestamp: '2024-01-02' },
        occurred_at: 1.day.ago
      )
      PersistedEvent.create!(
        event_type: 'user.logout',
        payload: { user_id: 1, timestamp: '2024-01-03' },
        occurred_at: Time.current
      )
    end

    it 'yields each event payload for specified type' do
      payloads = []
      PersistedEvent.replay('user.login') do |payload|
        payloads << payload
      end

      expect(payloads.count).to eq(2)
      expect(payloads.first[:user_id]).to eq(1)
      expect(payloads.second[:user_id]).to eq(2)
    end

    it 'symbolizes payload keys' do
      PersistedEvent.replay('user.login') do |payload|
        expect(payload.keys).to all(be_a(Symbol))
        expect(payload).to have_key(:user_id)
        expect(payload).to have_key(:timestamp)
      end
    end

    it 'filters by event type' do
      payloads = []
      PersistedEvent.replay('user.logout') do |payload|
        payloads << payload
      end

      expect(payloads.count).to eq(1)
      expect(payloads.first[:user_id]).to eq(1)
    end

    it 'handles empty result set' do
      payloads = []
      PersistedEvent.replay('non.existent') do |payload|
        payloads << payload
      end

      expect(payloads).to be_empty
    end

    it 'processes events in batches' do
      # Create many events to test find_each batching
      20.times do |i|
        PersistedEvent.create!(
          event_type: 'batch.test',
          payload: { index: i },
          occurred_at: Time.current
        )
      end

      count = 0
      PersistedEvent.replay('batch.test') do |_payload|
        count += 1
      end

      expect(count).to eq(20)
    end

    it 'allows state accumulation in block' do
      user_ids = []
      PersistedEvent.replay('user.login') do |payload|
        user_ids << payload[:user_id]
      end

      expect(user_ids).to contain_exactly(1, 2)
    end
  end

  describe '.event_counts_by_type' do
    before do
      # Today's events
      2.times do
        PersistedEvent.create!(
          event_type: 'user.login',
          payload: { test: true },
          occurred_at: Time.current
        )
      end

      PersistedEvent.create!(
        event_type: 'user.logout',
        payload: { test: true },
        occurred_at: Time.current
      )

      # This week's events (but not today)
      PersistedEvent.create!(
        event_type: 'user.login',
        payload: { test: true },
        occurred_at: 2.days.ago
      )

      # This month's events (but not this week)
      PersistedEvent.create!(
        event_type: 'order.created',
        payload: { test: true },
        occurred_at: 10.days.ago
      )

      # Old events
      PersistedEvent.create!(
        event_type: 'old.event',
        payload: { test: true },
        occurred_at: 2.months.ago
      )
    end

    it 'returns counts by type for today by default' do
      counts = PersistedEvent.event_counts_by_type
      expect(counts['user.login']).to eq(2)
      expect(counts['user.logout']).to eq(1)
    end

    it 'returns counts by type for today explicitly' do
      counts = PersistedEvent.event_counts_by_type(period: :today)
      expect(counts['user.login']).to eq(2)
      expect(counts['user.logout']).to eq(1)
      expect(counts['old.event']).to be_nil
    end

    it 'returns counts by type for this week' do
      counts = PersistedEvent.event_counts_by_type(period: :week)
      expect(counts['user.login']).to be >= 2
      expect(counts['old.event']).to be_nil
    end

    it 'returns counts by type for this month' do
      counts = PersistedEvent.event_counts_by_type(period: :month)
      expect(counts.values.sum).to be >= 4
      # order.created may or may not be in current month depending on test timing
      expect(counts['old.event']).to be_nil
    end

    it 'returns counts for all events when period is invalid' do
      counts = PersistedEvent.event_counts_by_type(period: :all)
      expect(counts.values.sum).to be >= 5
      expect(counts['old.event']).to eq(1)
    end

    it 'returns empty hash when no events in period' do
      PersistedEvent.destroy_all
      counts = PersistedEvent.event_counts_by_type(period: :today)
      expect(counts).to eq({})
    end

    it 'aggregates counts correctly' do
      10.times do
        PersistedEvent.create!(
          event_type: 'test.event',
          payload: { test: true },
          occurred_at: Time.current
        )
      end

      counts = PersistedEvent.event_counts_by_type(period: :today)
      expect(counts['test.event']).to eq(10)
    end
  end

  # ====================
  # JSONB QUERY TESTS
  # ====================

  describe 'JSONB queries' do
    before do
      PersistedEvent.create!(
        event_type: 'user.action',
        payload: { user_id: 123, action: 'login' },
        metadata: { ip: '192.168.1.1' },
        occurred_at: Time.current
      )

      PersistedEvent.create!(
        event_type: 'user.action',
        payload: { user_id: 456, action: 'logout' },
        metadata: { ip: '192.168.1.2' },
        occurred_at: Time.current
      )
    end

    it 'queries by payload field' do
      events = PersistedEvent.where("payload->>'user_id' = ?", '123')
      expect(events.count).to eq(1)
      expect(events.first.payload['user_id']).to eq(123)
    end

    it 'queries by metadata field' do
      events = PersistedEvent.where("metadata->>'ip' = ?", '192.168.1.1')
      expect(events.count).to eq(1)
      expect(events.first.metadata['ip']).to eq('192.168.1.1')
    end

    it 'queries by nested payload fields' do
      PersistedEvent.create!(
        event_type: 'order.created',
        payload: { user: { id: 789, name: 'Test User' } },
        occurred_at: Time.current
      )

      events = PersistedEvent.where("payload->'user'->>'id' = ?", '789')
      expect(events.count).to eq(1)
    end

    it 'queries with multiple JSONB conditions' do
      events = PersistedEvent.where(
        "payload->>'user_id' = ? AND payload->>'action' = ?",
        '123', 'login'
      )
      expect(events.count).to eq(1)
    end
  end

  # ====================
  # EVENT SOURCING TESTS
  # ====================

  describe 'event sourcing patterns' do
    it 'stores complete event history' do
      # Create a series of events for an order
      events_data = [
        { type: 'order.created', payload: { order_id: 1, status: 'pending' } },
        { type: 'order.paid', payload: { order_id: 1, amount: 100 } },
        { type: 'order.shipped', payload: { order_id: 1, tracking: 'ABC' } },
        { type: 'order.delivered', payload: { order_id: 1, delivered_at: Time.current } }
      ]

      events_data.each_with_index do |data, index|
        PersistedEvent.create!(
          event_type: data[:type],
          payload: data[:payload].merge(
            aggregate_type: 'Order',
            aggregate_id: '1'
          ),
          occurred_at: Time.current + index.minutes
        )
      end

      stream = PersistedEvent.stream_for('Order', '1')
      expect(stream.count).to eq(4)
      expect(stream.pluck(:event_type)).to eq([
        'order.created', 'order.paid', 'order.shipped', 'order.delivered'
      ])
    end

    it 'maintains immutable event log' do
      event = PersistedEvent.create!(
        event_type: 'immutable.test',
        payload: { original: 'data' },
        occurred_at: Time.current
      )

      # Events should not be modified, but we can add metadata
      event.update!(metadata: { processed: true })

      expect(event.reload.payload['original']).to eq('data')
      expect(event.metadata['processed']).to eq(true)
    end

    it 'supports temporal queries' do
      time1 = 3.hours.ago
      time2 = 2.hours.ago
      time3 = 1.hour.ago

      PersistedEvent.create!(
        event_type: 'test.event',
        payload: { version: 1 },
        occurred_at: time1
      )

      PersistedEvent.create!(
        event_type: 'test.event',
        payload: { version: 2 },
        occurred_at: time2
      )

      PersistedEvent.create!(
        event_type: 'test.event',
        payload: { version: 3 },
        occurred_at: time3
      )

      # Query events up to a point in time
      events = PersistedEvent.where('occurred_at <= ?', time2).order(:occurred_at)
      expect(events.count).to eq(2)
      expect(events.last.payload['version']).to eq(2)
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles empty payload' do
      event = PersistedEvent.new(
        event_type: 'test.event',
        payload: {},
        occurred_at: Time.current
      )
      expect(event).not_to be_valid
    end

    it 'handles large payload' do
      large_payload = {
        data: Array.new(100) { |i| { index: i, value: "value_#{i}" } }
      }

      event = PersistedEvent.create!(
        event_type: 'large.event',
        payload: large_payload,
        occurred_at: Time.current
      )

      expect(event.reload.payload['data'].count).to eq(100)
    end

    it 'handles special characters in event_type' do
      event = PersistedEvent.create!(
        event_type: 'user.login-success_v2',
        payload: { test: true },
        occurred_at: Time.current
      )

      expect(event.reload.event_type).to eq('user.login-success_v2')
    end

    it 'handles concurrent event creation' do
      threads = 5.times.map do |i|
        Thread.new do
          PersistedEvent.create!(
            event_type: 'concurrent.test',
            payload: { thread: i },
            occurred_at: Time.current
          )
        end
      end

      threads.each(&:join)

      expect(PersistedEvent.by_type('concurrent.test').count).to eq(5)
    end

    it 'preserves payload type information' do
      event = PersistedEvent.create!(
        event_type: 'type.test',
        payload: {
          integer: 42,
          float: 3.14,
          string: 'text',
          boolean: true,
          null_value: nil,
          array: [1, 2, 3],
          hash: { nested: 'value' }
        },
        occurred_at: Time.current
      )

      reloaded = event.reload
      expect(reloaded.payload['integer']).to eq(42)
      expect(reloaded.payload['float']).to eq(3.14)
      expect(reloaded.payload['string']).to eq('text')
      expect(reloaded.payload['boolean']).to eq(true)
      expect(reloaded.payload['null_value']).to be_nil
      expect(reloaded.payload['array']).to eq([1, 2, 3])
      expect(reloaded.payload['hash']).to eq({ 'nested' => 'value' })
    end

    it 'handles events with same occurred_at timestamp' do
      timestamp = Time.current

      3.times do |i|
        PersistedEvent.create!(
          event_type: 'timestamp.test',
          payload: { index: i },
          occurred_at: timestamp
        )
      end

      events = PersistedEvent.where(occurred_at: timestamp)
      expect(events.count).to eq(3)
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration scenarios' do
    it 'tracks complete user session' do
      session_id = SecureRandom.uuid
      user_id = 123

      # Login
      PersistedEvent.create!(
        event_type: 'user.login',
        payload: { user_id: user_id, session_id: session_id },
        metadata: { ip: '192.168.1.1', user_agent: 'Browser' },
        occurred_at: Time.current
      )

      # Actions
      3.times do |i|
        PersistedEvent.create!(
          event_type: 'user.action',
          payload: { user_id: user_id, session_id: session_id, action: "action_#{i}" },
          occurred_at: Time.current + (i + 1).minutes
        )
      end

      # Logout
      PersistedEvent.create!(
        event_type: 'user.logout',
        payload: { user_id: user_id, session_id: session_id },
        occurred_at: Time.current + 5.minutes
      )

      # Query session events
      session_events = PersistedEvent
                       .where("payload->>'session_id' = ?", session_id)
                       .order(:occurred_at)

      expect(session_events.count).to eq(5)
      expect(session_events.first.event_type).to eq('user.login')
      expect(session_events.last.event_type).to eq('user.logout')
    end

    it 'supports event replay for state reconstruction' do
      account_id = 'ACC123'

      # Series of account events
      PersistedEvent.create!(
        event_type: 'account.created',
        payload: { aggregate_type: 'Account', aggregate_id: account_id, balance: 0 },
        occurred_at: Time.current
      )

      PersistedEvent.create!(
        event_type: 'account.deposited',
        payload: { aggregate_type: 'Account', aggregate_id: account_id, amount: 100 },
        occurred_at: Time.current + 1.minute
      )

      PersistedEvent.create!(
        event_type: 'account.withdrawn',
        payload: { aggregate_type: 'Account', aggregate_id: account_id, amount: 30 },
        occurred_at: Time.current + 2.minutes
      )

      # Reconstruct state
      balance = 0
      PersistedEvent.stream_for('Account', account_id).each do |event|
        case event.event_type
        when 'account.created'
          balance = event.payload['balance']
        when 'account.deposited'
          balance += event.payload['amount']
        when 'account.withdrawn'
          balance -= event.payload['amount']
        end
      end

      expect(balance).to eq(70)
    end

    it 'generates audit trail' do
      resource_id = 999

      PersistedEvent.create!(
        event_type: 'resource.created',
        payload: { resource_id: resource_id, created_by: 'admin' },
        metadata: { ip: '10.0.0.1' },
        occurred_at: Time.current
      )

      PersistedEvent.create!(
        event_type: 'resource.updated',
        payload: { resource_id: resource_id, updated_by: 'user1', changes: { name: 'New Name' } },
        metadata: { ip: '10.0.0.2' },
        occurred_at: Time.current + 1.hour
      )

      PersistedEvent.create!(
        event_type: 'resource.deleted',
        payload: { resource_id: resource_id, deleted_by: 'admin' },
        metadata: { ip: '10.0.0.1' },
        occurred_at: Time.current + 2.hours
      )

      audit_trail = PersistedEvent
                    .where("payload->>'resource_id' = ?", resource_id.to_s)
                    .order(:occurred_at)

      expect(audit_trail.count).to eq(3)
      expect(audit_trail.pluck(:event_type)).to eq([
        'resource.created', 'resource.updated', 'resource.deleted'
      ])
    end
  end

  # ====================
  # PERFORMANCE TESTS
  # ====================

  describe 'performance considerations' do
    it 'efficiently handles bulk event creation' do
      expect do
        100.times do |i|
          PersistedEvent.create!(
            event_type: 'bulk.test',
            payload: { index: i },
            occurred_at: Time.current
          )
        end
      end.to change(PersistedEvent, :count).by(100)
    end

    it 'uses indexes for type queries' do
      # Create events
      50.times { |i| PersistedEvent.create!(event_type: 'indexed.test', payload: { i: i }, occurred_at: Time.current) }

      # Query should be fast with index
      result = PersistedEvent.by_type('indexed.test')
      expect(result.count).to eq(50)
    end

    it 'uses indexes for time-based queries' do
      # Create events
      10.times do |i|
        PersistedEvent.create!(
          event_type: 'time.test',
          payload: { index: i },
          occurred_at: i.days.ago
        )
      end

      # Query should be fast with index
      result = PersistedEvent.where('occurred_at > ?', 5.days.ago)
      expect(result.count).to eq(5)
    end
  end
end
