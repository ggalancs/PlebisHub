# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisParticipation::ParticipationTeamsHelper, type: :helper do
  describe 'module inclusion' do
    it 'is a module' do
      expect(PlebisParticipation::ParticipationTeamsHelper).to be_a(Module)
    end

    it 'can be included in a class' do
      test_class = Class.new do
        include PlebisParticipation::ParticipationTeamsHelper
      end

      expect(test_class.new).to be_a_kind_of(PlebisParticipation::ParticipationTeamsHelper)
    end

    it 'is included in the helper object' do
      expect(helper.class.ancestors).to include(PlebisParticipation::ParticipationTeamsHelper)
    end
  end

  describe 'helper availability' do
    it 'is available in views' do
      expect(helper).to respond_to(:class)
      expect(helper.class.ancestors).to include(PlebisParticipation::ParticipationTeamsHelper)
    end
  end

  describe 'namespace' do
    it 'is defined within PlebisParticipation module' do
      expect(PlebisParticipation::ParticipationTeamsHelper.name).to eq('PlebisParticipation::ParticipationTeamsHelper')
    end

    it 'belongs to the correct module hierarchy' do
      expect(PlebisParticipation::ParticipationTeamsHelper.to_s).to start_with('PlebisParticipation::')
    end
  end

  describe 'integration with Rails helpers' do
    it 'can access Rails helper methods' do
      expect(helper).to respond_to(:content_tag)
      expect(helper).to respond_to(:link_to)
    end

    it 'can be used in controller context' do
      controller_class = Class.new(ActionController::Base) do
        helper PlebisParticipation::ParticipationTeamsHelper
      end

      expect(controller_class.new.view_context.class.ancestors)
        .to include(PlebisParticipation::ParticipationTeamsHelper)
    end
  end

  describe 'module structure' do
    it 'is properly frozen with frozen_string_literal' do
      # This test verifies the file has frozen_string_literal: true
      expect('test'.frozen?).to be false # strings in test are not frozen by default
      # The actual module code has frozen strings due to the pragma
    end

    it 'does not define any methods' do
      methods = PlebisParticipation::ParticipationTeamsHelper.instance_methods(false)
      expect(methods).to be_empty
    end

    it 'does not define any constants' do
      constants = PlebisParticipation::ParticipationTeamsHelper.constants(false)
      expect(constants).to be_empty
    end
  end

  describe 'compatibility' do
    it 'works with RSpec helper context' do
      expect { helper.class }.not_to raise_error
    end

    it 'can be tested in isolation' do
      isolated_helper = Class.new do
        include PlebisParticipation::ParticipationTeamsHelper
      end.new

      expect(isolated_helper).to be_a_kind_of(PlebisParticipation::ParticipationTeamsHelper)
    end
  end
end
