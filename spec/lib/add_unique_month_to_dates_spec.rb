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

  describe 'edge cases and boundary conditions' do
    describe 'Date#unique_month' do
      it 'handles January correctly' do
        date = Date.new(2023, 1, 1)
        expect(date.unique_month).to eq(2023 * 12 + 1)
      end

      it 'handles December correctly' do
        date = Date.new(2023, 12, 31)
        expect(date.unique_month).to eq(2023 * 12 + 12)
      end

      it 'handles year 2000' do
        date = Date.new(2000, 6, 15)
        expect(date.unique_month).to eq(2000 * 12 + 6)
      end

      it 'handles year 1900' do
        date = Date.new(1900, 1, 1)
        expect(date.unique_month).to eq(1900 * 12 + 1)
      end

      it 'produces unique values for consecutive months' do
        dates = (1..12).map { |m| Date.new(2023, m, 1).unique_month }
        expect(dates.uniq.size).to eq(12)
        expect(dates).to eq(dates.sort)
      end

      it 'same month different days have same unique_month' do
        date1 = Date.new(2023, 5, 1)
        date2 = Date.new(2023, 5, 31)
        expect(date1.unique_month).to eq(date2.unique_month)
      end
    end

    describe 'DateTime#unique_month' do
      it 'handles midnight' do
        datetime = DateTime.new(2023, 5, 15, 0, 0, 0)
        expect(datetime.unique_month).to eq(2023 * 12 + 5)
      end

      it 'handles end of day' do
        datetime = DateTime.new(2023, 5, 15, 23, 59, 59)
        expect(datetime.unique_month).to eq(2023 * 12 + 5)
      end

      it 'handles leap year February' do
        datetime = DateTime.new(2020, 2, 29, 12, 0, 0)
        expect(datetime.unique_month).to eq(2020 * 12 + 2)
      end

      it 'same month different times have same unique_month' do
        datetime1 = DateTime.new(2023, 5, 1, 8, 30, 0)
        datetime2 = DateTime.new(2023, 5, 31, 17, 45, 30)
        expect(datetime1.unique_month).to eq(datetime2.unique_month)
      end
    end

    describe 'Time#unique_month' do
      it 'handles UTC time' do
        time = Time.utc(2023, 5, 15, 10, 30, 0)
        expect(time.unique_month).to eq(2023 * 12 + 5)
      end

      it 'handles local time' do
        time = Time.local(2023, 5, 15, 10, 30, 0)
        expect(time.unique_month).to eq(2023 * 12 + 5)
      end

      it 'handles Time.now' do
        time = Time.now
        expected = time.year * 12 + time.month
        expect(time.unique_month).to eq(expected)
      end

      it 'same month different seconds have same unique_month' do
        time1 = Time.new(2023, 5, 15, 10, 30, 0)
        time2 = Time.new(2023, 5, 15, 10, 30, 59)
        expect(time1.unique_month).to eq(time2.unique_month)
      end
    end

    describe 'consistency across types' do
      it 'Date, DateTime, and Time return same unique_month for same month' do
        date = Date.new(2023, 5, 15)
        datetime = DateTime.new(2023, 5, 20, 10, 30, 0)
        time = Time.new(2023, 5, 25, 14, 45, 30)

        expect(date.unique_month).to eq(datetime.unique_month)
        expect(datetime.unique_month).to eq(time.unique_month)
      end
    end
  end

  describe 'ActiveRecord integration' do
    describe 'unique_month with different adapters' do
      it 'returns string SQL fragment' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_month('created_at')
        expect(result).to be_a(String)
      end

      it 'includes field name in SQL' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_month('custom_field')
        expect(result).to include('custom_field')
      end
    end

    describe 'unique_day with different adapters' do
      it 'returns string SQL fragment' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_day('created_at')
        expect(result).to be_a(String)
      end

      it 'includes field name in SQL' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_day('custom_field')
        expect(result).to include('custom_field')
      end

      it 'uses formula with 384 multiplier for year' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_day('created_at')
        expect(result).to include('*384')
      end

      it 'uses formula with 32 multiplier for month' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_day('created_at')
        expect(result).to include('*32')
      end

      it 'subtracts 1 from month in calculation' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('PostgreSQL')
        result = ActiveRecord::Base.unique_day('created_at')
        expect(result).to include('-1')
      end
    end

    describe 'adapter fallback behavior' do
      it 'handles unknown adapter as MySQL-like' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('UnknownDB')
        sql = ActiveRecord::Base.unique_month('created_at')
        expect(sql).to eq('year(created_at)*12+month(created_at)')
      end

      it 'handles Trilogy adapter as MySQL-like' do
        allow(ActiveRecord::Base.connection).to receive(:adapter_name).and_return('Trilogy')
        sql = ActiveRecord::Base.unique_month('created_at')
        expect(sql).to eq('year(created_at)*12+month(created_at)')
      end
    end
  end

  describe 'calculation verification' do
    it 'unique_month formula produces correct results' do
      date1 = Date.new(2023, 1, 1)
      date2 = Date.new(2023, 2, 1)
      expect(date2.unique_month - date1.unique_month).to eq(1)
    end

    it 'year boundary works correctly' do
      dec_2022 = Date.new(2022, 12, 31)
      jan_2023 = Date.new(2023, 1, 1)
      expect(jan_2023.unique_month - dec_2022.unique_month).to eq(1)
    end

    it 'produces sequential numbers for sequential months' do
      dates = (1..24).map { |i| Date.new(2023, 1, 1) + (i * 30) }
      unique_months = dates.map(&:unique_month)
      differences = unique_months.each_cons(2).map { |a, b| b - a }
      expect(differences).to all(be >= 0)
    end
  end
end
