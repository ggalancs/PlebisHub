# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SpamFilter Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let!(:spam_filter) do
    SpamFilter.create!(
      name: 'Test Filter',
      code: 'user.email.include?("spam")',
      data: "spam@example.com\r\ntest@spam.com",
      query: 'created_at > ?',
      active: true,
      rules_json: {
        logic: 'AND',
        conditions: [
          {
            field: 'email',
            operator: 'contains',
            value: 'spam'
          }
        ]
      }.to_json
    )
  end

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/spam_filters' do
    it 'displays the index page' do
      get admin_spam_filters_path
      expect(response).to have_http_status(:success)
    end

    it 'shows spam filter columns' do
      get admin_spam_filters_path
      expect(response.body).to include('Test Filter')
      expect(response.body).to include(spam_filter.code)
    end

    it 'displays selectable column' do
      get admin_spam_filters_path
      expect(response.body).to match(/selectable.*column/i)
    end

    it 'displays id column' do
      get admin_spam_filters_path
      expect(response.body).to include(spam_filter.id.to_s)
    end

    it 'displays name column' do
      get admin_spam_filters_path
      expect(response.body).to include('Test Filter')
    end

    it 'displays code column' do
      get admin_spam_filters_path
      expect(response.body).to include(spam_filter.code)
    end

    it 'displays truncated data' do
      get admin_spam_filters_path
      expect(response.body).to include('spam@example.com')
    end

    it 'displays active status' do
      get admin_spam_filters_path
      expect(response.body).to match(/active|activo/i)
    end

    it 'displays actions column' do
      get admin_spam_filters_path
      expect(response.body).to match(/View|Edit|Delete/i)
    end
  end

  describe 'GET /admin/spam_filters/:id' do
    it 'displays the show page' do
      get admin_spam_filter_path(spam_filter)
      expect(response).to have_http_status(:success)
    end

    it 'shows spam filter details' do
      get admin_spam_filter_path(spam_filter)
      expect(response.body).to include('Test Filter')
      expect(response.body).to include(spam_filter.code)
    end

    it 'has run action item' do
      get admin_spam_filter_path(spam_filter)
      expect(response.body).to include('Ejecutar')
      expect(response.body).to include(run_admin_spam_filter_path(id: spam_filter.id))
    end
  end

  describe 'GET /admin/spam_filters/new' do
    it 'displays the new form' do
      get new_admin_spam_filter_path
      expect(response).to have_http_status(:success)
    end

    it 'has form fields for all permitted params' do
      get new_admin_spam_filter_path
      expect(response.body).to include('spam_filter[name]')
      expect(response.body).to include('spam_filter[code]')
      expect(response.body).to include('spam_filter[data]')
      expect(response.body).to include('spam_filter[query]')
      expect(response.body).to include('spam_filter[active]')
    end
  end

  describe 'POST /admin/spam_filters' do
    let(:valid_params) do
      {
        spam_filter: {
          name: 'New Filter',
          code: 'user.email.include?("test")',
          data: "test@example.com",
          query: 'confirmed_at IS NULL',
          active: false,
          rules_json: {
            logic: 'OR',
            conditions: [
              {
                field: 'email',
                operator: 'contains',
                value: 'test'
              }
            ]
          }.to_json
        }
      }
    end

    it 'creates a new spam filter' do
      expect do
        post admin_spam_filters_path, params: valid_params
      end.to change(SpamFilter, :count).by(1)
    end

    it 'redirects to the spam filter show page' do
      post admin_spam_filters_path, params: valid_params
      expect(response).to redirect_to(admin_spam_filter_path(SpamFilter.last))
    end

    it 'creates with correct attributes' do
      post admin_spam_filters_path, params: valid_params
      filter = SpamFilter.last
      expect(filter.name).to eq('New Filter')
      expect(filter.code).to eq('user.email.include?("test")')
      expect(filter.active).to be false
    end
  end

  describe 'GET /admin/spam_filters/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_spam_filter_path(spam_filter)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_spam_filter_path(spam_filter)
      expect(response.body).to include('Test Filter')
      expect(response.body).to include(spam_filter.code)
    end
  end

  describe 'PUT /admin/spam_filters/:id' do
    let(:update_params) do
      {
        spam_filter: {
          name: 'Updated Filter',
          active: false
        }
      }
    end

    it 'updates the spam filter' do
      put admin_spam_filter_path(spam_filter), params: update_params
      spam_filter.reload
      expect(spam_filter.name).to eq('Updated Filter')
      expect(spam_filter.active).to be false
    end

    it 'redirects to the show page' do
      put admin_spam_filter_path(spam_filter), params: update_params
      expect(response).to redirect_to(admin_spam_filter_path(spam_filter))
    end
  end

  describe 'DELETE /admin/spam_filters/:id' do
    it 'deletes the spam filter' do
      expect do
        delete admin_spam_filter_path(spam_filter)
      end.to change(SpamFilter, :count).by(-1)
    end

    it 'redirects to the index page' do
      delete admin_spam_filter_path(spam_filter)
      expect(response).to redirect_to(admin_spam_filters_path)
    end
  end

  describe 'custom actions' do
    describe 'GET /admin/spam_filters/:id/run' do
      let!(:matching_user) do
        create(:user, :confirmed, email: 'spam@example.com', verified: false, banned: false)
      end

      before do
        allow_any_instance_of(SpamFilter).to receive(:query_count).and_return(1)
      end

      it 'displays the run page' do
        get run_admin_spam_filter_path(id: spam_filter.id)
        expect(response).to have_http_status(:success)
      end

      it 'shows filter name' do
        get run_admin_spam_filter_path(id: spam_filter.id)
        expect(response.body).to include('Test Filter')
      end

      it 'displays progress elements' do
        get run_admin_spam_filter_path(id: spam_filter.id)
        expect(response.body).to include('js-spam-filter-progress')
        expect(response.body).to include('js-spam-filter-total')
      end

      it 'displays user results container' do
        get run_admin_spam_filter_path(id: spam_filter.id)
        expect(response.body).to include('js-spam-filter-users')
      end

      it 'has back link' do
        get run_admin_spam_filter_path(id: spam_filter.id)
        expect(response.body).to include('Volver')
        expect(response.body).to include(admin_spam_filter_path(id: spam_filter.id))
      end
    end

    describe 'GET /admin/spam_filters/:id/more' do
      let!(:matching_user) do
        create(:user, :confirmed, first_name: 'Test', last_name: 'User',
               email: 'spam@example.com', phone: '123456789',
               verified: false, banned: false)
      end

      before do
        allow_any_instance_of(SpamFilter).to receive(:run).with('0', '10').and_return([matching_user])
        allow(matching_user).to receive(:vote_town_name).and_return('Madrid')
        allow(matching_user).to receive(:vote_autonomy_name).and_return('Madrid')
      end

      it 'returns user results' do
        get more_admin_spam_filter_path(id: spam_filter.id, offset: 0, limit: 10)
        expect(response).to have_http_status(:success)
      end

      it 'displays user information' do
        get more_admin_spam_filter_path(id: spam_filter.id, offset: 0, limit: 10)
        expect(response.body).to include(matching_user.full_name)
        expect(response.body).to include(matching_user.email)
      end

      it 'links to user admin page' do
        get more_admin_spam_filter_path(id: spam_filter.id, offset: 0, limit: 10)
        expect(response.body).to include(admin_user_path(matching_user))
      end

      it 'shows ban block link when users found' do
        get more_admin_spam_filter_path(id: spam_filter.id, offset: 0, limit: 10)
        expect(response.body).to include('Banear bloque')
        expect(response.body).to include(ban_admin_spam_filter_path(id: spam_filter.id))
      end

      context 'when no users found' do
        before do
          allow_any_instance_of(SpamFilter).to receive(:run).with('0', '10').and_return([])
        end

        it 'does not show ban link' do
          get more_admin_spam_filter_path(id: spam_filter.id, offset: 0, limit: 10)
          expect(response.body).not_to include('Banear bloque')
        end
      end
    end

    describe 'GET /admin/spam_filters/:id/ban' do
      let!(:user_to_ban) do
        create(:user, :confirmed, email: 'spam@example.com', verified: false, banned: false)
      end

      before do
        allow(User).to receive(:ban_users).with([user_to_ban.id.to_s], true).and_return(true)
        allow(User).to receive(:where).with(id: [user_to_ban.id.to_s]).and_return([user_to_ban])
        allow(ActiveAdmin::Comment).to receive(:create).and_return(true)
      end

      it 'bans users' do
        get ban_admin_spam_filter_path(id: spam_filter.id, users: [user_to_ban.id])
        expect(User).to have_received(:ban_users).with([user_to_ban.id.to_s], true)
      end

      it 'creates admin comment' do
        get ban_admin_spam_filter_path(id: spam_filter.id, users: [user_to_ban.id])
        expect(ActiveAdmin::Comment).to have_received(:create)
      end

      it 'redirects to spam filter show page' do
        get ban_admin_spam_filter_path(id: spam_filter.id, users: [user_to_ban.id])
        expect(response).to redirect_to(admin_spam_filter_path(id: spam_filter.id))
      end
    end
  end

  describe 'permitted parameters' do
    it 'permits name' do
      post admin_spam_filters_path, params: {
        spam_filter: {
          name: 'Permitted Name',
          query: 'true',
          rules_json: { logic: 'AND', conditions: [] }.to_json
        }
      }
      expect(SpamFilter.last.name).to eq('Permitted Name')
    end

    it 'permits code' do
      post admin_spam_filters_path, params: {
        spam_filter: {
          name: 'Test',
          code: 'permitted_code',
          query: 'true',
          rules_json: { logic: 'AND', conditions: [] }.to_json
        }
      }
      expect(SpamFilter.last.code).to eq('permitted_code')
    end

    it 'permits data' do
      post admin_spam_filters_path, params: {
        spam_filter: {
          name: 'Test',
          data: "line1\r\nline2",
          query: 'true',
          rules_json: { logic: 'AND', conditions: [] }.to_json
        }
      }
      expect(SpamFilter.last.data).to eq("line1\r\nline2")
    end

    it 'permits query' do
      post admin_spam_filters_path, params: {
        spam_filter: {
          name: 'Test',
          query: 'custom_query',
          rules_json: { logic: 'AND', conditions: [] }.to_json
        }
      }
      expect(SpamFilter.last.query).to eq('custom_query')
    end

    it 'permits active' do
      post admin_spam_filters_path, params: {
        spam_filter: {
          name: 'Test',
          query: 'true',
          active: true,
          rules_json: { logic: 'AND', conditions: [] }.to_json
        }
      }
      expect(SpamFilter.last.active).to be true
    end
  end

  describe 'menu configuration' do
    it 'appears under Users parent menu' do
      get admin_spam_filters_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'index display' do
    it 'truncates data display' do
      long_filter = SpamFilter.create!(
        name: 'Long Data Filter',
        data: "line1\r\nline2\r\nline3\r\nline4",
        query: 'true',
        rules_json: { logic: 'AND', conditions: [] }.to_json
      )

      get admin_spam_filters_path
      expect(response.body).to include('line1')
      expect(response.body).to include('...')
    end
  end
end
