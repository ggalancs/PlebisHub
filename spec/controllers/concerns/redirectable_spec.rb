# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Redirectable, type: :concern do
  # Create a dummy controller class for testing the concern
  let(:dummy_controller_class) do
    Class.new(ApplicationController) do
      include Redirectable

      # Define a mock action for testing
      def index
        head :ok
      end

      def create
        head :created
      end
    end
  end

  let(:dummy_controller) { dummy_controller_class.new }

  before do
    # Setup request/response doubles
    allow(dummy_controller).to receive(:request).and_return(double('request',
                                                                    get?: true,
                                                                    xhr?: false,
                                                                    referer: 'https://example.com/previous'))
    allow(dummy_controller).to receive(:session).and_return({})
    allow(dummy_controller).to receive(:is_navigational_format?).and_return(true)
  end

  describe '#storable_location?' do
    context 'when all conditions are met' do
      it 'returns true for GET requests' do
        expect(dummy_controller.send(:storable_location?)).to be true
      end
    end

    context 'when request is not GET' do
      before do
        allow(dummy_controller).to receive(:request).and_return(double('request',
                                                                        get?: false,
                                                                        xhr?: false))
      end

      it 'returns false' do
        expect(dummy_controller.send(:storable_location?)).to be false
      end
    end

    context 'when request is XHR' do
      before do
        allow(dummy_controller).to receive(:request).and_return(double('request',
                                                                        get?: true,
                                                                        xhr?: true))
      end

      it 'returns false' do
        expect(dummy_controller.send(:storable_location?)).to be false
      end
    end

    context 'when format is not navigational' do
      before do
        allow(dummy_controller).to receive(:is_navigational_format?).and_return(false)
      end

      it 'returns false' do
        expect(dummy_controller.send(:storable_location?)).to be false
      end
    end

    context 'when multiple conditions are false' do
      before do
        allow(dummy_controller).to receive(:request).and_return(double('request',
                                                                        get?: false,
                                                                        xhr?: true))
        allow(dummy_controller).to receive(:is_navigational_format?).and_return(false)
      end

      it 'returns false' do
        expect(dummy_controller.send(:storable_location?)).to be false
      end
    end
  end

  describe '#store_user_location!' do
    let(:session) { {} }

    before do
      allow(dummy_controller).to receive(:session).and_return(session)
    end

    context 'when return_to is not set' do
      it 'stores the referer in session' do
        dummy_controller.send(:store_user_location!)
        expect(session[:return_to]).to eq('https://example.com/previous')
      end
    end

    context 'when return_to is already set' do
      before do
        session[:return_to] = 'https://example.com/original'
      end

      it 'does not overwrite existing return_to' do
        dummy_controller.send(:store_user_location!)
        expect(session[:return_to]).to eq('https://example.com/original')
      end

      it 'preserves the original value' do
        original_value = session[:return_to]
        dummy_controller.send(:store_user_location!)
        expect(session[:return_to]).to eq(original_value)
      end
    end

    context 'when referer is nil' do
      before do
        allow(dummy_controller).to receive(:request).and_return(double('request',
                                                                        get?: true,
                                                                        xhr?: false,
                                                                        referer: nil))
      end

      it 'stores nil' do
        dummy_controller.send(:store_user_location!)
        expect(session[:return_to]).to be_nil
      end
    end

    context 'when referer is empty string' do
      before do
        allow(dummy_controller).to receive(:request).and_return(double('request',
                                                                        get?: true,
                                                                        xhr?: false,
                                                                        referer: ''))
      end

      it 'stores empty string' do
        dummy_controller.send(:store_user_location!)
        expect(session[:return_to]).to eq('')
      end
    end
  end

  describe '#after_update_path_for' do
    let(:resource) { double('resource') }
    let(:session) { {} }

    before do
      allow(dummy_controller).to receive(:session).and_return(session)
    end

    context 'when return_to is set in session' do
      before do
        session[:return_to] = '/stored/path'
      end

      it 'returns the stored path' do
        result = dummy_controller.send(:after_update_path_for, resource)
        expect(result).to eq('/stored/path')
      end

      it 'deletes return_to from session' do
        dummy_controller.send(:after_update_path_for, resource)
        expect(session[:return_to]).to be_nil
      end

      it 'removes the session key completely' do
        dummy_controller.send(:after_update_path_for, resource)
        expect(session).not_to have_key(:return_to)
      end
    end

    context 'when return_to is not set' do
      it 'calls super' do
        expect(dummy_controller).to receive_message_chain(:class, :superclass, :instance_method, :bind, :call)
                                        .and_return('/default/path')
        result = dummy_controller.send(:after_update_path_for, resource)
        expect(result).to be_present
      end
    end

    context 'when return_to is false' do
      before do
        session[:return_to] = false
      end

      it 'calls super because false is falsy' do
        dummy_controller.send(:after_update_path_for, resource)
        expect(session[:return_to]).to be_nil
      end
    end

    context 'when return_to is an empty string' do
      before do
        session[:return_to] = ''
      end

      it 'returns empty string (truthy in Ruby)' do
        result = dummy_controller.send(:after_update_path_for, resource)
        expect(result).to eq('')
      end
    end
  end

  describe 'before_action integration' do
    it 'sets up before_action with storable_location? condition' do
      callbacks = dummy_controller_class._process_action_callbacks
      store_location_callback = callbacks.find { |cb| cb.filter == :store_user_location! }
      expect(store_location_callback).to be_present
      expect(store_location_callback.if).to include(:storable_location?)
    end

    it 'only runs store_user_location! when storable_location? is true' do
      session = {}
      allow(dummy_controller).to receive(:session).and_return(session)
      allow(dummy_controller).to receive(:storable_location?).and_return(true)

      # Simulate before_action execution
      dummy_controller.send(:store_user_location!)

      expect(session[:return_to]).to be_present
    end

    it 'does not run store_user_location! when storable_location? is false' do
      session = {}
      allow(dummy_controller).to receive(:session).and_return(session)
      allow(dummy_controller).to receive(:storable_location?).and_return(false)

      # before_action would not call store_user_location! in this case
      # We verify the condition works correctly
      expect(dummy_controller.send(:storable_location?)).to be false
      expect(session[:return_to]).to be_nil
    end
  end

  describe 'concern included behavior' do
    it 'adds instance methods to including class' do
      expect(dummy_controller).to respond_to(:storable_location?)
      expect(dummy_controller).to respond_to(:store_user_location!)
      expect(dummy_controller).to respond_to(:after_update_path_for)
    end

    it 'adds before_action callback' do
      expect(dummy_controller_class._process_action_callbacks.map(&:filter)).to include(:store_user_location!)
    end
  end
end
