# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MicrocreditController, type: :controller do
  # ========================================
  # ALIAS CONTROLLER TESTS
  # ========================================
  # This file tests the backward compatibility alias for
  # PlebisMicrocredit::MicrocreditController

  describe 'class inheritance' do
    it 'is a subclass of PlebisMicrocredit::MicrocreditController' do
      expect(MicrocreditController.superclass).to eq(PlebisMicrocredit::MicrocreditController)
    end

    it 'inherits before_action filters from parent controller' do
      parent_filters = PlebisMicrocredit::MicrocreditController._process_action_callbacks.map(&:filter)
      child_filters = MicrocreditController._process_action_callbacks.map(&:filter)

      parent_filters.each do |filter|
        expect(child_filters).to include(filter)
      end
    end

    it 'has the same controller_name as parent' do
      expect(MicrocreditController.controller_name).to eq(PlebisMicrocredit::MicrocreditController.controller_name)
    end
  end

  describe 'backward compatibility' do
    it 'can be instantiated' do
      expect { MicrocreditController.new }.not_to raise_error
    end

    it 'responds to index action' do
      expect(MicrocreditController.action_methods).to include('index')
    end

    it 'responds to info action' do
      expect(MicrocreditController.action_methods).to include('info')
    end

    it 'responds to new_loan action' do
      expect(MicrocreditController.action_methods).to include('new_loan')
    end

    it 'responds to create_loan action' do
      expect(MicrocreditController.action_methods).to include('create_loan')
    end

    it 'responds to renewal action' do
      expect(MicrocreditController.action_methods).to include('renewal')
    end
  end

  describe 'controller class' do
    it 'is defined in the global namespace' do
      expect(defined?(::MicrocreditController)).to eq('constant')
    end

    it 'has the same ancestors except itself' do
      parent_ancestors = PlebisMicrocredit::MicrocreditController.ancestors
      child_ancestors = MicrocreditController.ancestors

      # Child should include parent in its ancestors
      expect(child_ancestors).to include(PlebisMicrocredit::MicrocreditController)
    end
  end
end
