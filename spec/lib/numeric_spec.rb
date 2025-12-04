# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/numeric'

RSpec.describe Numeric do
  describe '#percent' do
    context 'with integers' do
      it 'converts 100 to 1.0' do
        expect(100.percent).to eq(1.0)
      end

      it 'converts 50 to 0.5' do
        expect(50.percent).to eq(0.5)
      end

      it 'converts 25 to 0.25' do
        expect(25.percent).to eq(0.25)
      end

      it 'converts 10 to 0.1' do
        expect(10.percent).to eq(0.1)
      end

      it 'converts 1 to 0.01' do
        expect(1.percent).to eq(0.01)
      end

      it 'converts 0 to 0.0' do
        expect(0.percent).to eq(0.0)
      end

      it 'handles negative numbers' do
        expect(-50.percent).to eq(-0.5)
      end

      it 'handles numbers greater than 100' do
        expect(200.percent).to eq(2.0)
      end
    end

    context 'with floats' do
      it 'converts 50.5 to 0.505' do
        expect(50.5.percent).to eq(0.505)
      end

      it 'converts 33.33 to 0.3333' do
        expect(33.33.percent).to eq(0.3333)
      end

      it 'converts 0.5 to 0.005' do
        expect(0.5.percent).to eq(0.005)
      end
    end

    context 'with edge cases' do
      it 'handles very large numbers' do
        expect(10_000.percent).to eq(100.0)
      end

      it 'handles very small numbers' do
        expect(0.01.percent).to eq(0.0001)
      end
    end
  end

  describe '#percent_of' do
    context 'with integers' do
      it 'calculates 50 as percent of 100' do
        expect(50.percent_of(100)).to eq(50.0)
      end

      it 'calculates 25 as percent of 100' do
        expect(25.percent_of(100)).to eq(25.0)
      end

      it 'calculates 75 as percent of 150' do
        expect(75.percent_of(150)).to eq(50.0)
      end

      it 'calculates 30 as percent of 60' do
        expect(30.percent_of(60)).to eq(50.0)
      end

      it 'calculates 1 as percent of 10' do
        expect(1.percent_of(10)).to eq(10.0)
      end

      it 'handles zero numerator' do
        expect(0.percent_of(100)).to eq(0.0)
      end
    end

    context 'with floats' do
      it 'calculates 33.33 as percent of 100' do
        expect(33.33.percent_of(100)).to eq(33.33)
      end

      it 'calculates 50.5 as percent of 100' do
        expect(50.5.percent_of(100)).to eq(50.5)
      end

      it 'calculates decimal results' do
        expect(1.percent_of(3)).to be_within(0.01).of(33.33)
      end
    end

    context 'with negative numbers' do
      it 'handles negative numerator' do
        expect(-50.percent_of(100)).to eq(-50.0)
      end

      it 'handles negative denominator' do
        expect(50.percent_of(-100)).to eq(-50.0)
      end

      it 'handles both negative' do
        expect(-50.percent_of(-100)).to eq(50.0)
      end
    end

    context 'with percentages greater than 100' do
      it 'calculates 150 as percent of 100' do
        expect(150.percent_of(100)).to eq(150.0)
      end

      it 'calculates 200 as percent of 100' do
        expect(200.percent_of(100)).to eq(200.0)
      end
    end

    context 'with very small denominators' do
      it 'calculates 1 as percent of 0.5' do
        expect(1.percent_of(0.5)).to eq(200.0)
      end

      it 'calculates 5 as percent of 2' do
        expect(5.percent_of(2)).to eq(250.0)
      end
    end

    context 'with real-world examples' do
      it 'calculates test score percentage' do
        expect(45.percent_of(50)).to eq(90.0)
      end

      it 'calculates completion percentage' do
        expect(7.percent_of(10)).to eq(70.0)
      end

      it 'calculates discount percentage' do
        expect(15.percent_of(100)).to eq(15.0)
      end
    end

    context 'with edge cases' do
      it 'handles very large numbers' do
        expect(1_000_000.percent_of(10_000_000)).to eq(10.0)
      end

      it 'handles very small numbers' do
        expect(0.001.percent_of(0.01)).to eq(10.0)
      end
    end
  end
end
