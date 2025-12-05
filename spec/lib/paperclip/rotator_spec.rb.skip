# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Paperclip::Rotator, skip: 'Requires Paperclip gem which is not installed' do
  let(:attachment) { double('attachment', name: :photo) }
  let(:instance) { double('instance', rotate: { photo: '90' }) }
  let(:rotator) { described_class.new('file.jpg', {}, attachment) }

  before do
    allow(rotator).to receive(:instance_variable_get).with(:@attachment).and_return(attachment)
    allow(attachment).to receive(:instance).and_return(instance)
  end

  describe '#transformation_command' do
    context 'when rotation is specified' do
      it 'includes rotation command' do
        allow(rotator).to receive(:rotate_command).and_return(' -rotate 90 ')
        allow(rotator).to receive_message_chain(:super, :join).and_return('other commands')
        result = rotator.transformation_command
        expect(result).to include('-rotate 90')
      end

      it 'appends super transformation commands' do
        allow(rotator).to receive(:rotate_command).and_return(' -rotate 90 ')
        allow_any_instance_of(Paperclip::Thumbnail).to receive(:transformation_command).and_return(['resize', 'convert'])
        result = rotator.transformation_command
        expect(result).to include('90')
      end
    end

    context 'when no rotation is specified' do
      before do
        allow(instance).to receive(:rotate).and_return({})
      end

      it 'returns super transformation commands' do
        expect(rotator).to receive(:rotate_command).and_return(nil)
        allow_any_instance_of(Paperclip::Thumbnail).to receive(:transformation_command).and_return(['commands'])
        result = rotator.transformation_command
        expect(result).to eq(['commands'])
      end
    end
  end

  describe '#rotate_command' do
    it 'returns rotation command when rotate is present' do
      result = rotator.send(:rotate_command)
      expect(result).to eq(' -rotate 90 ')
    end

    it 'returns nil when instance does not respond to rotate' do
      allow(instance).to receive(:respond_to?).with(:rotate).and_return(false)
      result = rotator.send(:rotate_command)
      expect(result).to be_nil
    end

    it 'returns nil when rotation value is not present' do
      allow(instance).to receive(:rotate).and_return({ photo: nil })
      result = rotator.send(:rotate_command)
      expect(result).to be_nil
    end

    it 'handles different rotation angles' do
      allow(instance).to receive(:rotate).and_return({ photo: '180' })
      result = rotator.send(:rotate_command)
      expect(result).to eq(' -rotate 180 ')
    end

    it 'uses attachment name as key' do
      allow(instance).to receive(:rotate).and_return({ photo: '90', avatar: '45' })
      allow(attachment).to receive(:name).and_return(:avatar)
      rotator = described_class.new('file.jpg', {}, attachment)
      allow(rotator).to receive(:instance_variable_get).with(:@attachment).and_return(attachment)
      result = rotator.send(:rotate_command)
      expect(result).to eq(' -rotate 45 ')
    end
  end

  describe 'inheritance from Paperclip::Thumbnail' do
    it 'is a subclass of Paperclip::Thumbnail' do
      expect(described_class.superclass).to eq(Paperclip::Thumbnail)
    end
  end
end
