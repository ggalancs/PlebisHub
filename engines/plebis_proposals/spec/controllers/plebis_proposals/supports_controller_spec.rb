# frozen_string_literal: true

require 'rails_helper'

module PlebisProposals
  RSpec.describe SupportsController, type: :controller do
    routes { PlebisProposals::Engine.routes }

    let(:user) { create(:user) }
    let(:proposal) { create(:proposal) }

    before { sign_in user }

    describe 'authentication' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to sign in' do
          post :create, params: { proposal_id: proposal.id }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'POST #create' do
      context 'with supportable proposal' do
        before do
          allow_any_instance_of(Proposal).to receive(:supportable?).with(user).and_return(true)
        end

        it 'creates a new support' do
          expect do
            post :create, params: { proposal_id: proposal.id }
          end.to change(user.supports, :count).by(1)
        end

        it 'redirects to proposal path' do
          post :create, params: { proposal_id: proposal.id }
          expect(response).to redirect_to(proposal_path(proposal))
        end

        it 'sets success notice' do
          post :create, params: { proposal_id: proposal.id }
          expect(flash[:notice]).to be_present
        end

        it 'logs the support creation' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/support_created/))
          post :create, params: { proposal_id: proposal.id }
        end

        it 'includes user and proposal ids in log' do
          expect(Rails.logger).to receive(:info) do |log_json|
            log_data = JSON.parse(log_json)
            expect(log_data['user_id']).to eq(user.id)
            expect(log_data['proposal_id']).to eq(proposal.id)
          end
          post :create, params: { proposal_id: proposal.id }
        end
      end

      context 'with non-supportable proposal' do
        before do
          allow_any_instance_of(Proposal).to receive(:supportable?).with(user).and_return(false)
        end

        it 'does not create a support' do
          expect do
            post :create, params: { proposal_id: proposal.id }
          end.not_to change(user.supports, :count)
        end

        it 'redirects to proposal path' do
          post :create, params: { proposal_id: proposal.id }
          expect(response).to redirect_to(proposal_path(proposal))
        end

        it 'sets alert message' do
          post :create, params: { proposal_id: proposal.id }
          expect(flash[:alert]).to be_present
        end

        it 'logs the supportability check failure' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/support_not_supportable/))
          post :create, params: { proposal_id: proposal.id }
        end
      end

      context 'with invalid proposal id' do
        it 'handles RecordNotFound gracefully' do
          post :create, params: { proposal_id: 99999 }
          expect(response).to redirect_to(proposals_path)
          expect(flash[:alert]).to be_present
        end

        it 'logs the not found event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/support_proposal_not_found/))
          post :create, params: { proposal_id: 99999 }
        end
      end

      context 'when support creation fails' do
        before do
          allow_any_instance_of(Proposal).to receive(:supportable?).with(user).and_return(true)
          allow(user.supports).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'redirects to proposal path' do
          post :create, params: { proposal_id: proposal.id }
          expect(response).to redirect_to(proposal_path(proposal))
        end

        it 'sets alert message' do
          post :create, params: { proposal_id: proposal.id }
          expect(flash[:alert]).to be_present
        end

        it 'logs the creation failure' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/support_creation_failed/))
          post :create, params: { proposal_id: proposal.id }
        end
      end

      context 'when a general error occurs' do
        before do
          allow(Proposal).to receive(:find).and_raise(StandardError, 'Database error')
        end

        it 'redirects to proposals path' do
          post :create, params: { proposal_id: proposal.id }
          expect(response).to redirect_to(proposals_path)
        end

        it 'sets alert message' do
          post :create, params: { proposal_id: proposal.id }
          expect(flash[:alert]).to be_present
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/support_creation_error/))
          post :create, params: { proposal_id: proposal.id }
        end

        it 'includes error details in log' do
          expect(Rails.logger).to receive(:error) do |log_json|
            log_data = JSON.parse(log_json)
            expect(log_data['error_class']).to eq('StandardError')
            expect(log_data['error_message']).to eq('Database error')
          end
          post :create, params: { proposal_id: proposal.id }
        end
      end
    end

    describe 'private methods' do
      describe '#log_security_event' do
        before do
          allow_any_instance_of(Proposal).to receive(:supportable?).with(user).and_return(false)
        end

        it 'logs with correct structure' do
          expect(Rails.logger).to receive(:info) do |log_json|
            log_data = JSON.parse(log_json)
            expect(log_data['event']).to be_present
            expect(log_data['controller']).to eq('supports')
            expect(log_data['timestamp']).to be_present
          end
          post :create, params: { proposal_id: proposal.id }
        end
      end

      describe '#log_error' do
        before do
          allow(Proposal).to receive(:find).and_raise(StandardError, 'Test error')
        end

        it 'logs with correct structure' do
          expect(Rails.logger).to receive(:error) do |log_json|
            log_data = JSON.parse(log_json)
            expect(log_data['event']).to be_present
            expect(log_data['controller']).to eq('supports')
            expect(log_data['backtrace']).to be_present
          end
          post :create, params: { proposal_id: proposal.id }
        end
      end
    end
  end
end
