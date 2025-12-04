# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/add_unique_month_to_dates'

RSpec.describe 'AddUniqueMonthToDates' do
  describe 'Date#unique_month' do
    it 'calculates unique month for a date' do
      date = Date.new(2023, 5, 15)
      expect(date.unique_month).to eq(2023 * 12 + 5)
    end

    it 'returns different values for different months' do
      date1 = Date.new(2023, 5, 15)
      date2 = Date.new(2023, 6, 15)
      expect(date1.unique_month).to eq(24281)
      expect(date2.unique_month).to eq(24282)
    end

    it 'returns different values for different years' do
      date1 = Date.new(2023, 5, 15)
      date2 = Date.new(2024, 5, 15)
      expect(date2.unique_month).to eq(date1.unique_month + 12)
    end

    it 'works with different date formats' do
      date = Date.parse('2020-12-31')
      expect(date.unique_month).to eq(2020 * 12 + 12)
    end
  end

  describe 'DateTime#unique_month' do
    it 'calculates unique month for a datetime' do
      datetime = DateTime.new(2023, 5, 15, 10, 30, 0)
      expect(datetime.unique_month).to eq(2023 * 12 + 5)
    end

    it 'ignores time component' do
      datetime1 = DateTime.new(2023, 5, 15, 10, 30, 0)
      datetime2 = DateTime.new(2023, 5, 15, 23, 59, 59)
      expect(datetime1.unique_month).to eq(datetime2.unique_month)
    end

    it 'returns different values for different months' do
      datetime1 = DateTime.new(2023, 1, 1)
      datetime2 = DateTime.new(2023, 12, 31)
      expect(datetime2.unique_month).to eq(datetime1.unique_month + 11)
    end
  end

  describe 'Time#unique_month' do
    it 'calculates unique month for a time' do
      time = Time.new(2023, 5, 15, 10, 30, 0)
      expect(time.unique_month).to eq(2023 * 12 + 5)
    end

    it 'ignores time component' do
      time1 = Time.new(2023, 5, 15, 0, 0, 0)
      time2 = Time.new(2023, 5, 15, 23, 59, 59)
      expect(time1.unique_month).to eq(time2.unique_month)
    end

    it 'works with Time.current' do
      time = Time.current
      expected = time.year * 12 + time.month
      expect(time.unique_month).to eq(expected)
    end
  end

  describe 'ActiveRecord::Base.unique_month' do
    context 'with PostgreSQL adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
      end

      it 'returns PostgreSQL-specific SQL for unique_month' do
        sql = ActiveRecord::Base.unique_month('created_at')
        expect(sql).to eq('extract(year from created_at)*12+extract(month from created_at)')
      end

      it 'works with different field names' do
        sql = ActiveRecord::Base.unique_month('updated_at')
        expect(sql).to eq('extract(year from updated_at)*12+extract(month from updated_at)')
      end
    end

    context 'with SQLite adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('SQLite')
      end

      it 'returns SQLite-specific SQL for unique_month' do
        sql = ActiveRecord::Base.unique_month('created_at')
        expect(sql).to eq("strftime('%Y', created_at)*12+strftime('%m', created_at)")
      end
    end

    context 'with MySQL adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('MySQL')
      end

      it 'returns MySQL-specific SQL for unique_month' do
        sql = ActiveRecord::Base.unique_month('created_at')
        expect(sql).to eq('year(created_at)*12+month(created_at)')
      end
    end
  end

  describe 'ActiveRecord::Base.unique_day' do
    context 'with PostgreSQL adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
      end

      it 'returns PostgreSQL-specific SQL for unique_day' do
        sql = ActiveRecord::Base.unique_day('created_at')
        expect(sql).to eq('extract(year from created_at)*384+(extract(month from created_at)-1)*32+extract(day from created_at)')
      end

      it 'works with different field names' do
        sql = ActiveRecord::Base.unique_day('born_at')
        expect(sql).to eq('extract(year from born_at)*384+(extract(month from born_at)-1)*32+extract(day from born_at)')
      end
    end

    context 'with SQLite adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('SQLite')
      end

      it 'returns SQLite-specific SQL for unique_day' do
        sql = ActiveRecord::Base.unique_day('created_at')
        expect(sql).to eq("strftime('%Y', created_at)*384+(strftime('%m', created_at)-1)*32+strftime('%d', created_at)")
      end
    end

    context 'with MySQL adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('MySQL')
      end

      it 'returns MySQL-specific SQL for unique_day' do
        sql = ActiveRecord::Base.unique_day('created_at')
        expect(sql).to eq('year(created_at)*384+(month(created_at)-1)*32+day(created_at)')
      end
    end

    context 'with SQL Server adapter' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('SQL Server')
      end

      it 'returns SQL Server-specific SQL for unique_day' do
        sql = ActiveRecord::Base.unique_day('created_at')
        expect(sql).to eq('year(created_at)*384+(month(created_at)-1)*32+day(created_at)')
      end
    end
  end
end
