# frozen_string_literal: true

require 'rails_helper'

module PlebisProposals
  RSpec.describe ProposalsController, type: :controller do
    routes { PlebisProposals::Engine.routes }

    let(:user) { create(:user) }
    let(:proposal) { create(:proposal) }

    describe 'GET #index' do
      context 'with default filter' do
        it 'sets filter to popular' do
          get :index
          expect(assigns(:proposals)).to be_present
        end

        it 'loads hot proposals' do
          get :index
          expect(assigns(:hot)).to be_present
        end

        it 'renders the index template' do
          get :index
          expect(response).to render_template(:index)
        end

        it 'returns http success' do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      context 'with custom filter' do
        it 'uses the provided filter parameter' do
          get :index, params: { filter: 'hot' }
          expect(params[:filter]).to eq('hot')
        end
      end

      context 'when an error occurs' do
        before do
          allow(Proposal).to receive(:filter).and_raise(StandardError, 'Database error')
        end

        it 'handles the error gracefully' do
          get :index
          expect(assigns(:proposals)).to eq(Proposal.none)
          expect(assigns(:hot)).to eq([])
          expect(flash.now[:alert]).to be_present
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/proposals_index_error/))
          get :index
        end
      end

      context 'security logging' do
        it 'logs the index view event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/proposals_index_viewed/))
          get :index
        end

        it 'includes filter in log' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/hot/))
          get :index, params: { filter: 'hot' }
        end
      end
    end

    describe 'GET #show' do
      context 'with valid proposal' do
        it 'assigns the requested proposal' do
          get :show, params: { id: proposal.id }
          expect(assigns(:proposal)).to eq(proposal)
        end

        it 'renders the show template' do
          get :show, params: { id: proposal.id }
          expect(response).to render_template(:show)
        end

        it 'returns http success' do
          get :show, params: { id: proposal.id }
          expect(response).to have_http_status(:success)
        end

        it 'logs the view event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/proposal_viewed/))
          get :show, params: { id: proposal.id }
        end
      end

      context 'with invalid proposal id' do
        it 'redirects to proposals path' do
          get :show, params: { id: 99999 }
          expect(response).to redirect_to(proposals_path)
        end

        it 'sets an alert message' do
          get :show, params: { id: 99999 }
          expect(flash[:alert]).to be_present
        end

        it 'logs the not found event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/proposal_not_found/))
          get :show, params: { id: 99999 }
        end
      end

      context 'when an error occurs' do
        before do
          allow(Proposal).to receive(:reddit).and_raise(StandardError, 'Database error')
        end

        it 'redirects to proposals path' do
          get :show, params: { id: proposal.id }
          expect(response).to redirect_to(proposals_path)
        end

        it 'sets an alert message' do
          get :show, params: { id: proposal.id }
          expect(flash[:alert]).to be_present
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/proposal_show_error/))
          get :show, params: { id: proposal.id }
        end
      end
    end

    describe 'GET #info' do
      it 'renders the info template' do
        get :info
        expect(response).to render_template(:info)
      end

      it 'returns http success' do
        get :info
        expect(response).to have_http_status(:success)
      end

      it 'logs the info view event' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/proposals_info_viewed/))
        get :info
      end

      context 'when an error occurs' do
        before do
          allow(controller).to receive(:render).and_raise(StandardError, 'Template error')
        end

        it 'redirects to proposals path' do
          expect { get :info }.to raise_error(StandardError)
        end
      end
    end

    describe 'private methods' do
      describe '#log_security_event' do
        it 'logs with correct structure' do
          expect(Rails.logger).to receive(:info) do |log_json|
            log_data = JSON.parse(log_json)
            expect(log_data['event']).to be_present
            expect(log_data['timestamp']).to be_present
          end
          get :index
        end
      end

      describe '#log_error' do
        before do
          allow(Proposal).to receive(:filter).and_raise(StandardError, 'Test error')
        end

        it 'logs with correct structure' do
          expect(Rails.logger).to receive(:error) do |log_json|
            log_data = JSON.parse(log_json)
            expect(log_data['event']).to be_present
            expect(log_data['error_class']).to eq('StandardError')
            expect(log_data['error_message']).to be_present
          end
          get :index
        end
      end
    end
  end
end
