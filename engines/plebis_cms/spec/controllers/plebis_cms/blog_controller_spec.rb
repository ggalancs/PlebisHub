# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe BlogController, type: :controller do
    routes { PlebisCms::Engine.routes }

    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:category) { create(:category, :active) }
    let!(:published_post) { create(:post, :published, category: category) }
    let!(:draft_post) { create(:post, category: category, published_at: nil) }

    describe 'GET #index' do
      context 'as regular user' do
        before { sign_in user if user }

        it 'shows only published posts' do
          get :index
          expect(assigns(:posts)).to include(published_post)
          expect(assigns(:posts)).not_to include(draft_post)
        end

        it 'loads categories' do
          get :index
          expect(assigns(:categories)).to include(category)
        end

        it 'renders the index template' do
          get :index
          expect(response).to render_template(:index)
        end

        it 'paginates posts' do
          get :index
          expect(assigns(:posts).current_page).to eq(1)
        end

        it 'logs the view event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/blog_index_viewed/))
          get :index
        end
      end

      context 'as admin' do
        before { sign_in admin }

        it 'shows all posts including drafts' do
          get :index
          expect(assigns(:posts)).to include(published_post, draft_post)
        end

        it 'logs admin access' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/"admin":true/))
          get :index
        end
      end

      context 'as guest' do
        it 'shows only published posts' do
          get :index
          expect(assigns(:posts)).to include(published_post)
          expect(assigns(:posts)).not_to include(draft_post)
        end
      end

      context 'error handling' do
        before do
          allow(PlebisCms::Post).to receive(:published).and_raise(StandardError, 'DB error')
        end

        it 'redirects to root on error' do
          get :index
          expect(response).to redirect_to(main_app.root_path)
          expect(flash[:alert]).to be_present
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/blog_index_error/))
          get :index
        end
      end
    end

    describe 'GET #post' do
      context 'as regular user' do
        before { sign_in user if user }

        it 'shows published post' do
          get :post, params: { id: published_post.id }
          expect(assigns(:post)).to eq(published_post)
        end

        it 'returns 404 for draft post' do
          expect do
            get :post, params: { id: draft_post.id }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'logs the view event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/blog_post_viewed/))
          get :post, params: { id: published_post.id }
        end
      end

      context 'as admin' do
        before { sign_in admin }

        it 'shows published post' do
          get :post, params: { id: published_post.id }
          expect(assigns(:post)).to eq(published_post)
        end

        it 'shows draft post' do
          get :post, params: { id: draft_post.id }
          expect(assigns(:post)).to eq(draft_post)
        end
      end

      context 'with invalid id' do
        before { sign_in user }

        it 'redirects to blog index' do
          get :post, params: { id: 99999 }
          expect(response).to redirect_to(blog_index_path)
        end

        it 'sets alert message' do
          get :post, params: { id: 99999 }
          expect(flash[:alert]).to be_present
        end

        it 'logs the not found event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/blog_post_not_found/))
          get :post, params: { id: 99999 }
        end
      end

      context 'error handling' do
        before do
          sign_in user
          allow(PlebisCms::Post).to receive(:published).and_raise(StandardError)
        end

        it 'redirects to blog index on error' do
          get :post, params: { id: published_post.id }
          expect(response).to redirect_to(blog_index_path)
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/blog_post_error/))
          get :post, params: { id: published_post.id }
        end
      end
    end

    describe 'GET #category' do
      context 'as regular user' do
        before { sign_in user if user }

        it 'shows posts from category' do
          get :category, params: { id: category.id }
          expect(assigns(:category)).to eq(category)
          expect(assigns(:posts)).to include(published_post)
          expect(assigns(:posts)).not_to include(draft_post)
        end

        it 'logs the view event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/blog_category_viewed/))
          get :category, params: { id: category.id }
        end
      end

      context 'as admin' do
        before { sign_in admin }

        it 'shows all posts from category' do
          get :category, params: { id: category.id }
          expect(assigns(:posts)).to include(published_post, draft_post)
        end
      end

      context 'with invalid category id' do
        before { sign_in user }

        it 'redirects to blog index' do
          get :category, params: { id: 99999 }
          expect(response).to redirect_to(blog_index_path)
        end

        it 'logs the not found event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/blog_category_not_found/))
          get :category, params: { id: 99999 }
        end
      end

      context 'error handling' do
        before do
          sign_in user
          allow(PlebisCms::Category).to receive(:find).and_raise(StandardError)
        end

        it 'redirects on error' do
          get :category, params: { id: category.id }
          expect(response).to redirect_to(blog_index_path)
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/blog_category_error/))
          get :category, params: { id: category.id }
        end
      end
    end

    describe 'private #get_categories' do
      it 'loads active categories' do
        get :index
        expect(assigns(:categories)).to be_present
      end

      context 'error handling' do
        before do
          allow(PlebisCms::Category).to receive(:active).and_raise(StandardError)
        end

        it 'sets empty array on error' do
          get :index
          expect(assigns(:categories)).to eq([])
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/blog_categories_load_error/))
          get :index
        end
      end
    end
  end
end
