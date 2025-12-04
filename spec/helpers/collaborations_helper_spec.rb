# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollaborationsHelper, type: :helper do
  describe '#new_or_edit_collaboration_path' do
    context 'when collaboration is present' do
      let(:collaboration) { double('Collaboration', id: 1) }

      it 'calls and returns edit_collaboration_path' do
        result = helper.new_or_edit_collaboration_path(collaboration)
        expect(result).to eq(edit_collaboration_path)
      end

      it 'evaluates the truthy branch' do
        expect(helper.new_or_edit_collaboration_path(collaboration)).not_to be_nil
      end

      it 'returns same path for multiple calls with truthy value' do
        result1 = helper.new_or_edit_collaboration_path(collaboration)
        result2 = helper.new_or_edit_collaboration_path(collaboration)
        expect(result1).to eq(result2)
      end
    end

    context 'when collaboration is nil' do
      it 'calls and returns new_collaboration_path' do
        result = helper.new_or_edit_collaboration_path(nil)
        expect(result).to eq(new_collaboration_path)
      end

      it 'evaluates the falsy branch' do
        expect(helper.new_or_edit_collaboration_path(nil)).not_to be_nil
      end

      it 'returns same path for multiple calls with nil' do
        result1 = helper.new_or_edit_collaboration_path(nil)
        result2 = helper.new_or_edit_collaboration_path(nil)
        expect(result1).to eq(result2)
      end
    end

    context 'when collaboration is false' do
      it 'calls and returns new_collaboration_path' do
        result = helper.new_or_edit_collaboration_path(false)
        expect(result).to eq(new_collaboration_path)
      end

      it 'evaluates the falsy branch like nil' do
        expect(helper.new_or_edit_collaboration_path(false)).to eq(helper.new_or_edit_collaboration_path(nil))
      end

      it 'returns same path for multiple calls with false' do
        result1 = helper.new_or_edit_collaboration_path(false)
        result2 = helper.new_or_edit_collaboration_path(false)
        expect(result1).to eq(result2)
      end
    end

    context 'behavior verification' do
      it 'returns different paths for truthy vs falsy' do
        truthy_path = helper.new_or_edit_collaboration_path('something')
        falsy_path = helper.new_or_edit_collaboration_path(nil)
        expect(truthy_path).not_to eq(falsy_path)
      end

      it 'handles multiple truthy types consistently' do
        paths = [
          helper.new_or_edit_collaboration_path('string'),
          helper.new_or_edit_collaboration_path(123),
          helper.new_or_edit_collaboration_path([]),
          helper.new_or_edit_collaboration_path({})
        ]
        expect(paths.uniq.length).to eq(1)
      end

      it 'handles multiple falsy types consistently' do
        nil_path = helper.new_or_edit_collaboration_path(nil)
        false_path = helper.new_or_edit_collaboration_path(false)
        expect(nil_path).to eq(false_path)
      end
    end
  end

  describe '#number_to_euro' do
    it 'executes the method body' do
      # Force execution of line 11
      amount = 1000
      precision = 2
      result = helper.number_to_euro(amount, precision)
      expect(result).to be_a(String)
      expect(result).to include('€')
    end

    it 'converts cents to euros with default precision' do
      expect(helper.number_to_euro(1000)).to eq('10,00€')
    end

    it 'converts cents to euros with 2 decimal places' do
      expect(helper.number_to_euro(2500, 2)).to eq('25,00€')
    end

    it 'converts cents to euros with custom precision' do
      expect(helper.number_to_euro(1234, 2)).to eq('12,34€')
    end

    it 'converts cents to euros with 0 decimal places' do
      expect(helper.number_to_euro(1000, 0)).to eq('10€')
    end

    it 'converts cents to euros with 3 decimal places' do
      expect(helper.number_to_euro(12345, 3)).to eq('123,450€')
    end

    it 'handles zero amount' do
      expect(helper.number_to_euro(0)).to eq('0,00€')
    end

    it 'handles negative amounts' do
      expect(helper.number_to_euro(-1000)).to eq('-10,00€')
    end

    it 'handles small amounts' do
      expect(helper.number_to_euro(1)).to eq('0,01€')
    end

    it 'handles large amounts' do
      expect(helper.number_to_euro(1_000_000)).to eq('10.000,00€')
    end

    it 'handles amounts with odd cents' do
      expect(helper.number_to_euro(1999)).to eq('19,99€')
    end

    it 'handles precision of 1' do
      expect(helper.number_to_euro(1234, 1)).to eq('12,3€')
    end

    it 'handles precision of 4' do
      expect(helper.number_to_euro(123456, 4)).to eq('1.234,5600€')
    end

    it 'divides by 100.0 correctly for integer amounts' do
      expect(helper.number_to_euro(5000)).to eq('50,00€')
    end

    it 'formats with euro symbol after number' do
      result = helper.number_to_euro(100)
      expect(result).to end_with('€')
      expect(result).to start_with('1')
    end

    it 'uses dot as thousands separator' do
      expect(helper.number_to_euro(100_000_000)).to eq('1.000.000,00€')
    end

    it 'handles fractional cents correctly' do
      expect(helper.number_to_euro(1001)).to eq('10,01€')
    end
  end

  describe 'module inclusion' do
    it 'includes ActionView::Helpers::NumberHelper' do
      expect(CollaborationsHelper.included_modules).to include(ActionView::Helpers::NumberHelper)
    end
  end

  describe 'edge cases' do
    describe '#number_to_euro' do
      it 'handles very large numbers' do
        expect(helper.number_to_euro(999_999_999_999)).to eq('9.999.999.999,99€')
      end

      it 'handles very small negative numbers' do
        expect(helper.number_to_euro(-1)).to eq('-0,01€')
      end

      it 'handles zero precision with rounding' do
        expect(helper.number_to_euro(1550, 0)).to eq('16€')
      end

      it 'handles default precision parameter' do
        result = helper.number_to_euro(1000)
        expect(result).to match(/\d+,\d{2}€/)
      end
    end

    describe '#new_or_edit_collaboration_path' do
      it 'handles empty string as truthy and returns edit_collaboration_path' do
        result = helper.new_or_edit_collaboration_path('')
        expect(result).to eq(edit_collaboration_path)
      end

      it 'handles truthy objects and returns edit_collaboration_path' do
        collaboration = Object.new
        result = helper.new_or_edit_collaboration_path(collaboration)
        expect(result).to eq(edit_collaboration_path)
      end

      it 'handles arrays as truthy and returns edit_collaboration_path' do
        result = helper.new_or_edit_collaboration_path([1, 2, 3])
        expect(result).to eq(edit_collaboration_path)
      end

      it 'distinguishes between truthy and falsy values' do
        truthy_result = helper.new_or_edit_collaboration_path('something')
        falsy_result = helper.new_or_edit_collaboration_path(nil)
        expect(truthy_result).not_to eq(falsy_result)
      end
    end
  end
end
