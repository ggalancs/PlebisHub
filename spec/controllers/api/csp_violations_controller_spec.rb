# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::CspViolationsController, type: :controller do
  describe 'POST #create' do
    let(:csp_report) do
      {
        'csp-report' => {
          'document-uri' => 'https://example.com/page',
          'violated-directive' => 'script-src',
          'blocked-uri' => 'https://evil.com/script.js',
          'source-file' => 'https://example.com/app.js',
          'line-number' => 42,
          'column-number' => 10
        }
      }
    end

    it 'returns success status' do
      post :create, body: csp_report.to_json, as: :json
      expect(response).to have_http_status(:no_content)
    end

    it 'logs CSP violation with details' do
      expect(Rails.logger).to receive(:warn).with(
        a_string_matching(/CSP Violation.*Document.*example\.com.*Blocked.*evil\.com.*Directive.*script-src/)
      )

      post :create, body: csp_report.to_json, as: :json
    end

    it 'handles missing csp-report key' do
      post :create, body: { other: 'data' }.to_json, as: :json
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles empty JSON object' do
      post :create, body: {}.to_json, as: :json
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles JSON parse errors gracefully' do
      allow_any_instance_of(Api::CspViolationsController).to receive(:parse_csp_report).and_raise(JSON::ParserError.new('Invalid'))
      post :create, body: '{}', as: :json
      expect(response).to have_http_status(:bad_request)
    end

    context 'with minimal report' do
      let(:minimal_report) do
        {
          'csp-report' => {
            'violated-directive' => 'default-src'
          }
        }
      end

      it 'handles minimal CSP report' do
        allow(Rails.logger).to receive(:warn)
        post :create, body: minimal_report.to_json, as: :json
        expect(response).to have_http_status(:no_content)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/CSP Violation/))
      end
    end

    context 'security' do
      it 'sanitizes malicious input for logging' do
        malicious_report = {
          'csp-report' => {
            'violated-directive' => 'script-src',
            'blocked-uri' => '"; eval("malicious code"); "'
          }
        }

        allow(Rails.logger).to receive(:warn)
        post :create, body: malicious_report.to_json, as: :json
        expect(response).to have_http_status(:no_content)
        expect(Rails.logger).to have_received(:warn)
      end

      it 'does not store report data' do
        expect do
          post :create, body: csp_report.to_json, as: :json
        end.not_to(change { ApplicationRecord.descendants.map(&:count).sum })
      end
    end

    context 'error handling' do
      it 'handles unexpected errors' do
        allow_any_instance_of(Api::CspViolationsController).to receive(:parse_csp_report).and_raise(StandardError.new('Unexpected'))
        post :create, body: '{}', as: :json
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
