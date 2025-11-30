# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors Show', type: :request do
  describe 'GET /errors/404' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza página de error 404' do
        get '/errors/404'
        expect([200, 404]).to include(response.status)
      end

      it 'muestra título de error' do
        get '/errors/404'
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'B. ERROR BOX' do
      it 'tiene error_box con mensaje' do
        get '/errors/404'
        has_error_box = response.body.match?(/error.*box/i) || response.body.include?('404')
        expect(has_error_box).to be true
      end

      it 'tiene párrafo con mensaje de error' do
        get '/errors/404'
        expect(response.body).to include('<p>')
      end
    end

    describe 'C. ESTRUCTURA HTML' do
      it 'usa estructura content-content cols' do
        get '/errors/404'
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'usa row y col para layout' do
        get '/errors/404'
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end
    end
  end

  describe 'GET /errors/500' do
    it 'maneja errores 500' do
      get '/errors/500'
      expect([200, 500]).to include(response.status)
    end
  end
end
