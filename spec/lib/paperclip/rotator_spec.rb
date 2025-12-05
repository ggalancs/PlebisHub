# frozen_string_literal: true

require 'rails_helper'

# Stub Paperclip module and Thumbnail class since Paperclip has been replaced
module Paperclip
  class Thumbnail
    def initialize(file, options, attachment)
      @file = file
      @options = options
      @attachment = attachment
    end

    def transformation_command
      ['-resize', '100x100']
    end
  end
end

require 'paperclip/rotator'

RSpec.describe Paperclip::Rotator do
  let(:attachment) { double('attachment', name: :avatar, instance: model_instance) }
  let(:model_instance) { double('model_instance') }
  let(:rotator) { described_class.new('test.jpg', {}, attachment) }

  describe '#transformation_command' do
    context 'when rotate_command is present' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
        allow(model_instance).to receive(:rotate).and_return({ avatar: '90' })
      end

      it 'prepends rotate command to superclass command' do
        result = rotator.transformation_command
        expect(result).to include('-rotate 90')
        expect(result).to be_a(String)
      end

      it 'includes superclass transformation commands' do
        result = rotator.transformation_command
        expect(result).to include('-resize')
        expect(result).to include('100x100')
      end

      it 'joins commands with space' do
        result = rotator.transformation_command
        expect(result).to match(/-rotate\s+90.*-resize/)
      end
    end

    context 'when rotate_command is nil' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(false)
      end

      it 'returns only superclass transformation command' do
        result = rotator.transformation_command
        expect(result).to eq(['-resize', '100x100'])
      end

      it 'does not include rotate command' do
        result = rotator.transformation_command
        expect(result.to_s).not_to include('-rotate')
      end
    end
  end

  describe '#rotate_command' do
    context 'when model responds to rotate and has rotation data' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
        allow(model_instance).to receive(:rotate).and_return({ avatar: '90' })
      end

      it 'returns rotate command string' do
        result = rotator.send(:rotate_command)
        expect(result).to eq(' -rotate 90 ')
      end

      it 'includes correct rotation angle' do
        allow(model_instance).to receive(:rotate).and_return({ avatar: '180' })
        result = rotator.send(:rotate_command)
        expect(result).to include('180')
      end

      it 'includes -rotate flag' do
        result = rotator.send(:rotate_command)
        expect(result).to include('-rotate')
      end

      it 'wraps command with spaces' do
        result = rotator.send(:rotate_command)
        expect(result).to start_with(' ')
        expect(result).to end_with(' ')
      end
    end

    context 'when model does not respond to rotate' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(false)
      end

      it 'returns nil' do
        expect(rotator.send(:rotate_command)).to be_nil
      end
    end

    context 'when model responds to rotate but has no data for attachment' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
        allow(model_instance).to receive(:rotate).and_return({ other_attachment: '90' })
      end

      it 'returns nil' do
        expect(rotator.send(:rotate_command)).to be_nil
      end
    end

    context 'when model responds to rotate but data is nil' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
        allow(model_instance).to receive(:rotate).and_return(nil)
      end

      it 'returns nil' do
        expect(rotator.send(:rotate_command)).to be_nil
      end
    end

    context 'when model responds to rotate but attachment data is empty' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
        allow(model_instance).to receive(:rotate).and_return({ avatar: '' })
      end

      it 'returns nil' do
        expect(rotator.send(:rotate_command)).to be_nil
      end
    end

    context 'when model responds to rotate but attachment data is nil' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
        allow(model_instance).to receive(:rotate).and_return({ avatar: nil })
      end

      it 'returns nil' do
        expect(rotator.send(:rotate_command)).to be_nil
      end
    end

    context 'with different rotation angles' do
      before do
        allow(model_instance).to receive(:respond_to?).with(:rotate).and_return(true)
      end

      ['0', '90', '180', '270', '-90', '45'].each do |angle|
        it "handles #{angle} degrees rotation" do
          allow(model_instance).to receive(:rotate).and_return({ avatar: angle })
          result = rotator.send(:rotate_command)
          expect(result).to eq(" -rotate #{angle} ")
        end
      end
    end
  end

  describe 'integration with Paperclip::Thumbnail' do
    it 'inherits from Paperclip::Thumbnail' do
      expect(described_class.superclass).to eq(Paperclip::Thumbnail)
    end

    it 'can be instantiated like Thumbnail' do
      expect { described_class.new('test.jpg', {}, attachment) }.not_to raise_error
    end
  end
end
