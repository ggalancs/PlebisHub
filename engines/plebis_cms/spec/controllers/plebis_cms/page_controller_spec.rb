# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe PageController, type: :controller do
    routes { PlebisCms::Engine.routes }

    let(:user) { create(:user) }
    let(:page) { create(:page, require_login: false) }
    let(:protected_page) { create(:page, require_login: true) }

    describe 'authentication requirements' do
      it 'allows public access to show_form for public pages' do
        get :show_form, params: { id: page.id }
        expect(response).to have_http_status(:success)
      end

      it 'requires authentication for privacy_policy' do
        get :privacy_policy
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET #show_form' do
      context 'with valid page' do
        it 'loads the page' do
          get :show_form, params: { id: page.id }
          expect(assigns(:page)).to eq(page)
        end

        it 'sets meta description if present' do
          page_with_meta = create(:page, meta_description: 'Test description')
          get :show_form, params: { id: page_with_meta.id }
          expect(assigns(:meta_description)).to eq('Test description')
        end

        it 'renders formview_iframe for external links' do
          external_page = create(:page, link: 'https://forms.external.com/form/123')
          get :show_form, params: { id: external_page.id }
          expect(response).to render_template(:formview_iframe)
        end

        it 'renders form_iframe for internal forms' do
          internal_page = create(:page, link: 'internal_form', id_form: 77)
          get :show_form, params: { id: internal_page.id }
          expect(response).to render_template(:form_iframe)
        end
      end

      context 'with invalid page id' do
        it 'returns bad request for non-numeric id' do
          get :show_form, params: { id: 'invalid' }
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns bad request for negative id' do
          get :show_form, params: { id: -1 }
          expect(response).to have_http_status(:bad_request)
        end

        it 'logs invalid page id' do
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/Invalid page ID/))
          get :show_form, params: { id: 'invalid' }
        end
      end

      context 'with non-existent page' do
        it 'returns not found' do
          get :show_form, params: { id: 99999 }
          expect(response).to have_http_status(:not_found)
        end

        it 'logs page not found' do
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/Page not found/))
          get :show_form, params: { id: 99999 }
        end
      end

      context 'with protected page' do
        context 'when not logged in' do
          it 'redirects to login' do
            get :show_form, params: { id: protected_page.id }
            expect(response).to redirect_to(new_user_session_path)
          end

          it 'preserves meta information in flash' do
            protected_page.update(meta_description: 'Protected page')
            get :show_form, params: { id: protected_page.id }
            expect(flash.now[:metas]).to be_present
          end
        end

        context 'when logged in' do
          before { sign_in user }

          it 'shows the page' do
            get :show_form, params: { id: protected_page.id }
            expect(response).to have_http_status(:success)
          end
        end
      end

      context 'with user-specific parameters' do
        before { sign_in user }

        it 'adds user params to external URLs' do
          external_page = create(:page, link: 'https://forms.external.com/form')
          get :show_form, params: { id: external_page.id }
          expect(assigns(:url)).to include('participa_user_id')
        end

        it 'escapes user data in URLs' do
          user.update(first_name: 'Test&Name')
          external_page = create(:page, link: 'https://forms.external.com/form')
          get :show_form, params: { id: external_page.id }
          expect(assigns(:url)).to include(ERB::Util.url_encode('Test&Name'))
        end
      end
    end

    describe 'static pages' do
      before { sign_in user }

      it 'renders privacy_policy' do
        get :privacy_policy
        expect(response).to render_template(:privacy_policy)
      end

      it 'renders faq' do
        get :faq
        expect(response).to render_template(:faq)
      end

      it 'renders guarantees' do
        get :guarantees
        expect(response).to render_template(:guarantees)
      end

      it 'renders funding' do
        get :funding
        expect(response).to render_template(:funding)
      end
    end

    describe 'form pages' do
      before { sign_in user }

      it 'renders guarantees_form with correct form_id' do
        get :guarantees_form
        expect(response).to render_template(:form_iframe)
        expect(assigns(:title)).to be_present
        expect(assigns(:url)).to include('f=77')
      end

      it 'renders primarias_andalucia' do
        get :primarias_andalucia
        expect(response).to render_template(:form_iframe)
        expect(assigns(:title)).to eq('Primarias Andalucía')
      end

      it 'renders representantes_electorales_extranjeros' do
        get :representantes_electorales_extranjeros
        expect(response).to render_template(:form_iframe)
        expect(assigns(:title)).to be_present
      end
    end

    describe 'private #add_user_params' do
      before { sign_in user }

      it 'returns URL unchanged when not logged in' do
        sign_out user
        url = 'https://example.com'
        expect(controller.send(:add_user_params, url)).to eq(url)
      end

      it 'adds user parameters when logged in' do
        url = 'https://example.com'
        result = controller.send(:add_user_params, url)
        expect(result).to include('participa_user_id')
        expect(result).to include('participa_user_email')
      end

      it 'handles nil born_at gracefully' do
        user.update(born_at: nil)
        url = 'https://example.com'
        result = controller.send(:add_user_params, url)
        expect(result).to include('participa_user_born_at=')
      end

      it 'formats born_at correctly' do
        user.update(born_at: Date.new(1990, 5, 15))
        url = 'https://example.com'
        result = controller.send(:add_user_params, url)
        expect(result).to include('15%2F05%2F1990') # URL encoded date
      end
    end

    describe 'private #form_url' do
      before { sign_in user }

      it 'generates signed URL with form ID' do
        url = controller.send(:form_url, 77)
        expect(url).to include('f=77')
      end

      it 'includes user parameters' do
        url = controller.send(:form_url, 77)
        expect(url).to include('participa_user_id')
      end

      it 'signs the URL' do
        url = controller.send(:form_url, 77)
        expect(url).to include('_s=') # signature parameter
      end
    end

    describe '#set_metas' do
      it 'loads current elections' do
        election = create(:election, :active)
        get :show_form, params: { id: page.id }
        expect(assigns(:current_elections)).to include(election)
      end

      it 'sets default meta_description from secrets' do
        get :show_form, params: { id: page.id }
        expect(assigns(:meta_description)).to be_present
      end

      it 'sets default meta_image from secrets' do
        get :show_form, params: { id: page.id }
        expect(assigns(:meta_image)).to be_present
      end
    end
  end
end
