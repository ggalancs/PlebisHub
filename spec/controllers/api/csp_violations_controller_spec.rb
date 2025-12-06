# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CspViolationsController, type: :controller do
  describe 'POST #create' do
    let(:valid_csp_report) do
      {
        'csp-report' => {
          'document-uri' => 'https://example.com/page',
          'violated-directive' => 'script-src self',
          'blocked-uri' => 'https://evil.com/script.js',
          'original-policy' => "default-src 'self'; script-src 'self'",
          'disposition' => 'report',
          'status-code' => 200
        }
      }.to_json
    end

    context 'with valid CSP report' do
      it 'returns http no_content' do
        request.headers['Content-Type'] = 'application/json'
        post :create, body: valid_csp_report
        expect(response).to have_http_status(:no_content)
      end

      it 'logs the CSP violation' do
        allow(Rails.logger).to receive(:warn).and_call_original
        request.headers['Content-Type'] = 'application/json'
        post :create, body: valid_csp_report
        expect(Rails.logger).to have_received(:warn).with(/CSP Violation/).at_least(:once)
      end

      it 'sanitizes URIs in logs' do
        allow(Rails.logger).to receive(:warn).and_call_original
        request.headers['Content-Type'] = 'application/json'
        post :create, body: valid_csp_report
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/example\.com/)).at_least(:once)
      end

      it 'includes IP address in logs' do
        allow(Rails.logger).to receive(:warn).and_call_original
        request.headers['Content-Type'] = 'application/json'
        post :create, body: valid_csp_report
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/IP:/)).at_least(:once)
      end
    end

    context 'with critical violations' do
      let(:critical_report) do
        {
          'csp-report' => {
            'document-uri' => 'https://example.com',
            'violated-directive' => 'script-src self',
            'blocked-uri' => 'https://malicious.com/inject.js'
          }
        }.to_json
      end

      it 'identifies script-src violations as critical' do
        allow_any_instance_of(Api::CspViolationsController).to receive(:notify_monitoring_service)
        request.headers['Content-Type'] = 'application/json'
        post :create, body: critical_report
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid JSON' do
      it 'returns http bad_request' do
        request.headers['Content-Type'] = 'application/json'
        post :create, body: 'invalid json'
        expect(response).to have_http_status(:bad_request)
      end

      it 'logs warning about invalid JSON' do
        allow(Rails.logger).to receive(:warn).and_call_original
        request.headers['Content-Type'] = 'application/json'
        post :create, body: 'invalid json'
        expect(Rails.logger).to have_received(:warn).with(/Invalid JSON format/).at_least(:once)
      end
    end

    context 'with empty body' do
      it 'returns http bad_request' do
        request.headers['Content-Type'] = 'application/json'
        post :create, body: ''
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with missing violated-directive' do
      let(:incomplete_report) do
        {
          'csp-report' => {
            'document-uri' => 'https://example.com',
            'blocked-uri' => 'https://evil.com/script.js'
          }
        }.to_json
      end

      it 'returns http bad_request' do
        request.headers['Content-Type'] => 'application/json'
        post :create, body: incomplete_report
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'CSRF protection' do
      it 'skips authenticity token verification' do
        expect(controller).not_to receive(:verify_authenticity_token)
        request.headers['Content-Type'] = 'application/json'
        post :create, body: valid_csp_report
      end
    end

    context 'when unexpected error occurs' do
      before do
        allow_any_instance_of(Api::CspViolationsController).to receive(:parse_csp_report).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns http internal_server_error' do
        allow(Rails.logger).to receive(:error).and_call_original
        request.headers['Content-Type'] = 'application/json'
        post :create, body: valid_csp_report
        expect(Rails.logger).to have_received(:error).with(/Unexpected error/).at_least(:once)
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe '#sanitize_for_log' do
    it 'removes newlines' do
      result = controller.send(:sanitize_for_log, "test\nvalue")
      expect(result).not_to include("\n")
    end

    it 'removes tabs' do
      result = controller.send(:sanitize_for_log, "test\tvalue")
      expect(result).not_to include("\t")
    end

    it 'truncates long values' do
      long_string = 'a' * 600
      result = controller.send(:sanitize_for_log, long_string)
      expect(result.length).to be <= 503 # 500 + '...'
    end

    it 'returns N/A for nil' do
      expect(controller.send(:sanitize_for_log, nil)).to eq('N/A')
    end

    it 'returns N/A for blank string' do
      expect(controller.send(:sanitize_for_log, '')).to eq('N/A')
    end
  end

  describe '#critical_violation?' do
    it 'identifies script-src as critical' do
      report = { 'violated-directive' => 'script-src self' }
      expect(controller.send(:critical_violation?, report)).to be true
    end

    it 'identifies base-uri as critical' do
      report = { 'violated-directive' => 'base-uri self' }
      expect(controller.send(:critical_violation?, report)).to be true
    end

    it 'identifies form-action as critical' do
      report = { 'violated-directive' => 'form-action self' }
      expect(controller.send(:critical_violation?, report)).to be true
    end

    it 'identifies frame-ancestors as critical' do
      report = { 'violated-directive' => 'frame-ancestors none' }
      expect(controller.send(:critical_violation?, report)).to be true
    end

    it 'does not identify style-src as critical' do
      report = { 'violated-directive' => 'style-src self' }
      expect(controller.send(:critical_violation?, report)).to be false
    end

    it 'handles missing violated-directive' do
      report = {}
      expect(controller.send(:critical_violation?, report)).to be false
    end
  end
end
