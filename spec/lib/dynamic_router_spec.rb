# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/dynamic_router'

RSpec.describe DynamicRouter do
  describe '.database_ready?' do
    context 'when database is available' do
      it 'returns true' do
        allow(ActiveRecord::Base).to receive(:connection).and_return(true)
        expect(described_class.database_ready?).to be true
      end

      it 'establishes connection successfully' do
        connection = double('connection')
        expect(ActiveRecord::Base).to receive(:connection).and_return(connection)
        described_class.database_ready?
      end
    end

    context 'when database is not available' do
      it 'returns false on NoDatabaseError' do
        allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::NoDatabaseError)
        expect(described_class.database_ready?).to be false
      end

      it 'returns false on ConnectionNotEstablished' do
        allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::ConnectionNotEstablished)
        expect(described_class.database_ready?).to be false
      end

      it 'returns false on PG::ConnectionBad' do
        allow(ActiveRecord::Base).to receive(:connection).and_raise(PG::ConnectionBad)
        expect(described_class.database_ready?).to be false
      end
    end
  end

  describe '.load' do
    let(:mock_connection) { double('connection', table_exists?: true) }

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(mock_connection)
      allow(Rails.application.routes).to receive(:draw)
    end

    context 'when database is not ready' do
      before do
        allow(described_class).to receive(:database_ready?).and_return(false)
      end

      it 'returns early without loading routes' do
        expect(Rails.application.routes).not_to receive(:draw)
        described_class.load
      end

      it 'does not check for pages table' do
        expect(mock_connection).not_to receive(:table_exists?)
        described_class.load
      end
    end

    context 'when database is ready' do
      before do
        allow(described_class).to receive(:database_ready?).and_return(true)
      end

      context 'when pages table does not exist' do
        before do
          allow(mock_connection).to receive(:table_exists?).with('pages').and_return(false)
        end

        it 'does not draw routes' do
          expect(Rails.application.routes).not_to receive(:draw)
          described_class.load
        end
      end

      context 'when pages table exists' do
        let(:page1) { double('Page', id: 1, slug: 'about-us') }
        let(:page2) { double('Page', id: 2, slug: 'contact') }

        before do
          allow(mock_connection).to receive(:table_exists?).with('pages').and_return(true)
          allow(Page).to receive(:find_each).and_yield(page1).and_yield(page2)
        end

        it 'draws routes for all pages' do
          expect(Rails.application.routes).to receive(:draw)
          described_class.load
        end

        it 'creates routes with locale scope' do
          expect(Rails.application.routes).to receive(:draw) do |&block|
            routes_context = double('routes_context')
            expect(routes_context).to receive(:scope).with('/(:locale)', locale: /es|ca|eu/)
            routes_context.instance_eval(&block)
          end

          described_class.load
        end

        it 'iterates through all pages' do
          expect(Page).to receive(:find_each).and_yield(page1).and_yield(page2)
          allow(Rails.application.routes).to receive(:draw)
          described_class.load
        end
      end

      context 'when database errors occur' do
        it 'handles NoDatabaseError gracefully' do
          allow(mock_connection).to receive(:table_exists?).and_raise(ActiveRecord::NoDatabaseError)
          expect(Rails.logger).to receive(:warn).with('[DynamicRouter] Database not ready, skipping dynamic routes')
          expect { described_class.load }.not_to raise_error
        end

        it 'handles ConnectionNotEstablished gracefully' do
          allow(mock_connection).to receive(:table_exists?).and_raise(ActiveRecord::ConnectionNotEstablished)
          expect(Rails.logger).to receive(:warn).with('[DynamicRouter] Database not ready, skipping dynamic routes')
          expect { described_class.load }.not_to raise_error
        end

        it 'handles PG::ConnectionBad gracefully' do
          allow(mock_connection).to receive(:table_exists?).and_raise(PG::ConnectionBad)
          expect(Rails.logger).to receive(:warn).with('[DynamicRouter] Database not ready, skipping dynamic routes')
          expect { described_class.load }.not_to raise_error
        end
      end
    end
  end

  describe '.reload' do
    it 'reloads the application routes' do
      routes_reloader = double('routes_reloader')
      allow(Rails.application).to receive(:routes_reloader).and_return(routes_reloader)
      expect(routes_reloader).to receive(:reload!)

      described_class.reload
    end

    it 'calls reload! on the routes reloader' do
      routes_reloader = double('routes_reloader')
      expect(Rails.application).to receive(:routes_reloader).and_return(routes_reloader)
      expect(routes_reloader).to receive(:reload!)

      described_class.reload
    end
  end

  describe 'integration scenarios' do
    let(:mock_connection) { double('connection', table_exists?: true) }
    let(:page) { double('Page', id: 1, slug: 'test-page') }

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(mock_connection)
      allow(described_class).to receive(:database_ready?).and_return(true)
      allow(Page).to receive(:find_each).and_yield(page)
    end

    it 'complete flow: checks database, loads routes' do
      expect(described_class).to receive(:database_ready?).and_return(true)
      expect(mock_connection).to receive(:table_exists?).with('pages').and_return(true)
      expect(Page).to receive(:find_each)
      expect(Rails.application.routes).to receive(:draw)

      described_class.load
    end

    it 'handles full reload cycle' do
      routes_reloader = double('routes_reloader')
      allow(Rails.application).to receive(:routes_reloader).and_return(routes_reloader)
      expect(routes_reloader).to receive(:reload!)

      described_class.reload
    end
  end

  describe 'error handling' do
    it 'does not raise errors when database is unavailable' do
      allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::NoDatabaseError)
      allow(Rails.logger).to receive(:warn)

      expect { described_class.load }.not_to raise_error
    end

    it 'logs warning when database is unavailable' do
      allow(ActiveRecord::Base).to receive(:connection).and_raise(ActiveRecord::NoDatabaseError)
      expect(Rails.logger).to receive(:warn).with('[DynamicRouter] Database not ready, skipping dynamic routes')

      described_class.load
    end
  end

  describe 'locale configuration' do
    let(:mock_connection) { double('connection', table_exists?: true) }

    before do
      allow(ActiveRecord::Base).to receive(:connection).and_return(mock_connection)
      allow(described_class).to receive(:database_ready?).and_return(true)
      allow(Page).to receive(:find_each)
    end

    it 'supports Spanish locale' do
      expect(Rails.application.routes).to receive(:draw) do |&block|
        routes_context = double('routes_context')
        expect(routes_context).to receive(:scope).with('/(:locale)', hash_including(locale: /es|ca|eu/))
        routes_context.instance_eval(&block)
      end

      described_class.load
    end

    it 'supports Catalan locale' do
      expect(Rails.application.routes).to receive(:draw) do |&block|
        routes_context = double('routes_context')
        expect(routes_context).to receive(:scope).with('/(:locale)', hash_including(locale: /es|ca|eu/))
        routes_context.instance_eval(&block)
      end

      described_class.load
    end

    it 'supports Basque locale' do
      expect(Rails.application.routes).to receive(:draw) do |&block|
        routes_context = double('routes_context')
        expect(routes_context).to receive(:scope).with('/(:locale)', hash_including(locale: /es|ca|eu/))
        routes_context.instance_eval(&block)
      end

      described_class.load
    end
  end
end
