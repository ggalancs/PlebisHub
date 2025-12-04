# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MicrocreditHelper, type: :helper do
  describe 'module definition' do
    it 'is defined' do
      expect(MicrocreditHelper).to be_a(Module)
    end

    it 'can be included in a class' do
      test_class = Class.new do
        include MicrocreditHelper
      end

      expect(test_class.ancestors).to include(MicrocreditHelper)
    end
  end
end
