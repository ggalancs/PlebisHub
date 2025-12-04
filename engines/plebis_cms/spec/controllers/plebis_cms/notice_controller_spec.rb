# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe NoticeController, type: :controller do
    routes { PlebisCms::Engine.routes }

    let(:user) { create(:user) }
    let!(:notice1) { create(:notice, :sent, :active) }
    let!(:notice2) { create(:notice, :sent, :active) }

    before { sign_in user }

    describe 'authentication' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to sign in' do
          get :index
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'GET #index' do
      context 'with default pagination' do
        it 'loads sent and active notices' do
          get :index
          expect(assigns(:notices)).to include(notice1, notice2)
        end

        it 'uses page 1 by default' do
          get :index
          expect(assigns(:notices).current_page).to eq(1)
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

      context 'with page parameter' do
        it 'uses the provided page number' do
          get :index, params: { page: 2 }
          expect(assigns(:notices).current_page).to eq(2)
        end

        it 'handles empty page parameter' do
          get :index, params: { page: '' }
          expect(assigns(:notices).current_page).to eq(1)
        end
      end

      context 'scoping' do
        let!(:draft_notice) { create(:notice, sent_at: nil) }
        let!(:inactive_notice) { create(:notice, :sent, deleted_at: Time.current) }

        it 'only shows sent notices' do
          get :index
          expect(assigns(:notices)).not_to include(draft_notice)
        end

        it 'only shows active notices' do
          get :index
          expect(assigns(:notices)).not_to include(inactive_notice)
        end
      end
    end
  end
end
