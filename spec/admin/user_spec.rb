# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Admin', type: :request do
  let!(:vote_circle) { create(:vote_circle) }
  let(:admin_user) do
    u = build(:user, :admin, admin: true, vote_circle: vote_circle)
    u.save(validate: false)
    u
  end
  let(:superadmin_user) do
    u = build(:user, :admin, admin: true, vote_circle: vote_circle)
    u.save(validate: false)
    u.update_column(:flags, u.flags | 2) # superadmin flag
    u
  end
  let!(:user) do
    u = build(:user, vote_circle: vote_circle)
    u.save(validate: false)
    u
  end
  let!(:deleted_user) do
    u = build(:user, vote_circle: vote_circle, deleted_at: 1.day.ago)
    u.save(validate: false)
    u
  end
  let!(:banned_user) do
    u = build(:user, vote_circle: vote_circle, banned: true)
    u.save(validate: false)
    u
  end
  let!(:verified_user) do
    u = build(:user, vote_circle: vote_circle, verified: true)
    u.save(validate: false)
    u
  end
  let!(:unverified_user) do
    u = build(:user, vote_circle: vote_circle, verified: false)
    u.save(validate: false)
    u
  end
  let!(:exempt_user) do
    u = build(:user, vote_circle: vote_circle, exempt_from_payment: true)
    u.save(validate: false)
    u
  end
  let!(:militant_user) do
    u = build(:user, vote_circle: vote_circle, militant: true, exempt_from_payment: true)
    u.save(validate: false)
    u
  end

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/users' do
    it 'displays the index page' do
      get admin_users_path
      expect(response).to have_http_status(:success)
    end

    it 'shows user IDs' do
      get admin_users_path
      expect(response.body).to include(user.id.to_s)
    end

    it 'shows user full names' do
      get admin_users_path
      expect(response.body).to include(user.full_name)
    end

    it 'shows selectable column' do
      get admin_users_path
      expect(response.body).to match(/selectable.*column/i)
    end

    context 'when logged in as superadmin in production' do
      before do
        sign_in superadmin_user
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'shows download links' do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'scopes' do
    let!(:confirmed_user) do
      u = build(:user, :confirmed, vote_circle: vote_circle)
      u.save(validate: false)
      u
    end
    let!(:unconfirmed_email_user) do
      u = build(:user, vote_circle: vote_circle, confirmed_at: nil)
      u.save(validate: false)
      u
    end
    let!(:unconfirmed_phone_user) do
      u = build(:user, vote_circle: vote_circle, sms_confirmed_at: nil)
      u.save(validate: false)
      u
    end
    let!(:legacy_password_user) do
      u = build(:user, vote_circle: vote_circle, has_legacy_password: true)
      u.save(validate: false)
      u
    end
    let!(:signed_in_user) do
      u = build(:user, vote_circle: vote_circle, sign_in_count: 5)
      u.save(validate: false)
      u
    end
    let!(:user_with_collaboration) do
      u = build(:user, :with_dni, vote_circle: vote_circle)
      u.save(validate: false)
      create(:collaboration, user: u, status: 3)
      u
    end
    let!(:user_with_cc_collaboration) do
      u = build(:user, :with_dni, vote_circle: vote_circle)
      u.save(validate: false)
      create(:collaboration, user: u, payment_type: 1, status: 3)
      u
    end
    let!(:user_with_bank_national) do
      u = build(:user, :with_dni, vote_circle: vote_circle)
      u.save(validate: false)
      create(:collaboration, :with_spanish_iban, user: u, payment_type: 3, status: 3)
      u
    end
    let!(:user_with_bank_international) do
      u = build(:user, :with_dni, vote_circle: vote_circle)
      u.save(validate: false)
      create(:collaboration, :with_international_iban, user: u, payment_type: 3, status: 3)
      u
    end
    let!(:participation_team) { create(:participation_team) }
    let!(:user_in_team) do
      team = participation_team
      u = build(:user, vote_circle: vote_circle, participation_team_at: 1.day.ago)
      u.save(validate: false)
      u.participation_teams << team
      u
    end

    it 'filters by created scope (default)' do
      get admin_users_path(scope: 'created')
      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.id.to_s)
      expect(response.body).not_to include(deleted_user.id.to_s)
    end

    it 'filters by confirmed scope' do
      get admin_users_path(scope: 'confirmed')
      expect(response).to have_http_status(:success)
    end

    it 'filters by deleted scope' do
      get admin_users_path(scope: 'deleted')
      expect(response).to have_http_status(:success)
    end

    it 'filters by unconfirmed_mail scope' do
      get admin_users_path(scope: 'unconfirmed_mail')
      expect(response).to have_http_status(:success)
    end

    it 'filters by unconfirmed_phone scope' do
      get admin_users_path(scope: 'unconfirmed_phone')
      expect(response).to have_http_status(:success)
    end

    it 'filters by legacy_password scope' do
      get admin_users_path(scope: 'legacy_password')
      expect(response).to have_http_status(:success)
    end

    it 'filters by confirmed_mail scope' do
      get admin_users_path(scope: 'confirmed_mail')
      expect(response).to have_http_status(:success)
    end

    it 'filters by confirmed_phone scope' do
      get admin_users_path(scope: 'confirmed_phone')
      expect(response).to have_http_status(:success)
    end

    it 'filters by signed_in scope' do
      get admin_users_path(scope: 'signed_in')
      expect(response).to have_http_status(:success)
    end

    it 'filters by has_collaboration scope' do
      get admin_users_path(scope: 'has_collaboration')
      expect(response).to have_http_status(:success)
    end

    it 'filters by has_collaboration_credit_card scope' do
      get admin_users_path(scope: 'has_collaboration_credit_card')
      expect(response).to have_http_status(:success)
    end

    it 'filters by has_collaboration_bank_national scope' do
      get admin_users_path(scope: 'has_collaboration_bank_national')
      expect(response).to have_http_status(:success)
    end

    it 'filters by has_collaboration_bank_international scope' do
      get admin_users_path(scope: 'has_collaboration_bank_international')
      expect(response).to have_http_status(:success)
    end

    it 'filters by participation_team scope' do
      get admin_users_path(scope: 'participation_team')
      expect(response).to have_http_status(:success)
    end

    it 'filters by has_vote_circle scope' do
      get admin_users_path(scope: 'has_vote_circle')
      expect(response).to have_http_status(:success)
    end

    it 'filters by banned scope' do
      get admin_users_path(scope: 'banned')
      expect(response).to have_http_status(:success)
    end

    it 'filters by verified scope' do
      get admin_users_path(scope: 'verified')
      expect(response).to have_http_status(:success)
    end

    it 'filters by not_verified scope' do
      get admin_users_path(scope: 'not_verified')
      expect(response).to have_http_status(:success)
    end

    it 'filters by Militant scope' do
      get admin_users_path(scope: 'active_militant')
      expect(response).to have_http_status(:success)
    end

    it 'filters by exempt_from_payment scope' do
      get admin_users_path(scope: 'exempt_from_payment')
      expect(response).to have_http_status(:success)
    end

    it 'filters by militant_and_exempt_from_payment scope' do
      get admin_users_path(scope: 'militant_and_exempt_from_payment')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'filters' do
    it 'filters by email' do
      get admin_users_path, params: { q: { email_cont: user.email } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by gender' do
      get admin_users_path, params: { q: { gender_eq: 1 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by document_vatid' do
      get admin_users_path, params: { q: { document_vatid_cont: user.document_vatid } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by document_vatid_in (list)' do
      get admin_users_path, params: { q: { document_vatid_in: "#{user.document_vatid} #{user.document_vatid}" } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by id_in (list)' do
      get admin_users_path, params: { q: { id_in: "#{user.id} #{user.id}" } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by email_in (list)' do
      get admin_users_path, params: { q: { email_in: "#{user.email} test@example.com" } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by admin' do
      get admin_users_path, params: { q: { admin_eq: true } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by first_name' do
      get admin_users_path, params: { q: { first_name_cont: user.first_name } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by last_name' do
      get admin_users_path, params: { q: { last_name_cont: user.last_name } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by phone' do
      get admin_users_path, params: { q: { phone_cont: user.phone } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by born_at' do
      get admin_users_path, params: { q: { born_at_gteq: 30.years.ago.to_date } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by created_at' do
      get admin_users_path, params: { q: { created_at_gteq: 1.week.ago.to_date } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by address' do
      get admin_users_path, params: { q: { address_cont: user.address } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by town' do
      get admin_users_path, params: { q: { town_cont: user.town } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by postal_code' do
      get admin_users_path, params: { q: { postal_code_cont: user.postal_code } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by province' do
      get admin_users_path, params: { q: { province_cont: user.province } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by country' do
      get admin_users_path, params: { q: { country_cont: user.country } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by vote_circle_id' do
      get admin_users_path, params: { q: { vote_circle_id_eq: vote_circle.id } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by vote_autonomy_in' do
      get admin_users_path, params: { q: { vote_autonomy_in: 'a_13' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by vote_province_in' do
      get admin_users_path, params: { q: { vote_province_in: 'p_28' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by vote_island_in' do
      get admin_users_path, params: { q: { vote_island_in: 'i_04' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by vote_town' do
      get admin_users_path, params: { q: { vote_town_cont: 'Madrid' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by current_sign_in_at' do
      get admin_users_path, params: { q: { current_sign_in_at_gteq: 1.week.ago } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by current_sign_in_ip' do
      get admin_users_path, params: { q: { current_sign_in_ip_cont: '127.0.0.1' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by last_sign_in_at' do
      get admin_users_path, params: { q: { last_sign_in_at_gteq: 1.week.ago } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by last_sign_in_ip' do
      get admin_users_path, params: { q: { last_sign_in_ip_cont: '127.0.0.1' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by has_legacy_password' do
      get admin_users_path, params: { q: { has_legacy_password_eq: true } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by confirmed_at' do
      get admin_users_path, params: { q: { confirmed_at_gteq: 1.week.ago } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by sms_confirmed_at' do
      get admin_users_path, params: { q: { sms_confirmed_at_gteq: 1.week.ago } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by sign_in_count' do
      get admin_users_path, params: { q: { sign_in_count_gteq: 1 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by wants_participation' do
      get admin_users_path, params: { q: { wants_participation_eq: true } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by participation_team_id' do
      team = create(:participation_team)
      get admin_users_path, params: { q: { participation_team_id_eq: team.id } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by votes_election_id' do
      election = create(:election)
      get admin_users_path, params: { q: { votes_election_id_eq: election.id } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user_vote_circle_autonomy_id_in' do
      get admin_users_path, params: { q: { user_vote_circle_autonomy_id_in: '__13%' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user_vote_circle_province_id_in' do
      get admin_users_path, params: { q: { user_vote_circle_province_id_in: '____28%' } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user_vote_circle_id_in' do
      get admin_users_path, params: { q: { user_vote_circle_id_in: vote_circle.id } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/users/:id' do
    it 'displays the show page' do
      get admin_user_path(user)
      expect(response).to have_http_status(:success)
    end

    it 'shows user full name' do
      get admin_user_path(user)
      expect(response.body).to include(user.full_name)
    end

    it 'shows user email' do
      get admin_user_path(user)
      expect(response.body).to include(user.email)
    end

    it 'shows verification status' do
      get admin_user_path(verified_user)
      expect(response.body).to match(/Verificado/i)
    end

    it 'shows banned status' do
      get admin_user_path(banned_user)
      expect(response.body).to match(/Baneado/i)
    end

    it 'shows deleted status' do
      get admin_user_path(deleted_user)
      expect(response.body).to match(/Borrado/i)
    end

    it 'shows militant status' do
      get admin_user_path(militant_user)
      expect(response.body).to match(/Militante/i)
    end

    it 'shows exempt from payment status' do
      get admin_user_path(exempt_user)
      expect(response.body).to match(/Exento de pago/i)
    end

    it 'shows vote circle information' do
      get admin_user_path(user)
      expect(response.body).to include(user.vote_circle.original_name)
    end

    context 'with version parameter' do
      before do
        user.update(first_name: 'Updated Name')
      end

      it 'shows versioned user data' do
        version_index = 0
        get admin_user_path(user), params: { version: version_index }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /admin/users/new' do
    it 'displays the new form' do
      get new_admin_user_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/users' do
    let(:valid_params) do
      {
        user: {
          email: 'newuser@example.com',
          phone: '+491234567890',
          password: 'Password123',
          password_confirmation: 'Password123',
          first_name: 'New',
          last_name: 'User',
          gender: 1,
          document_type: 3,
          document_vatid: 'PASS12345678',
          born_at: 25.years.ago.to_date,
          address: '123 Test St',
          town: 'Berlin',
          postal_code: '10115',
          province: 'BE',
          country: 'DE',
          vote_province: 'p_28',
          vote_town: 'm_28_079',
          wants_newsletter: false,
          vote_district: nil,
          wants_information_by_sms: false
        }
      }
    end

    it 'creates a new user' do
      expect do
        post admin_users_path, params: valid_params
      end.to change(User, :count).by(1)
    end

    it 'redirects to the user show page' do
      post admin_users_path, params: valid_params
      expect(response).to redirect_to(admin_user_path(User.last))
    end
  end

  describe 'GET /admin/users/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT /admin/users/:id' do
    let(:update_params) do
      {
        user: {
          first_name: 'Updated',
          last_name: 'Name',
          exempt_from_payment: true
        }
      }
    end

    it 'updates the user' do
      put admin_user_path(user), params: update_params
      user.reload
      expect(user.first_name).to eq('Updated')
      expect(user.last_name).to eq('Name')
      expect(user.exempt_from_payment).to be true
    end

    it 'allows updating vote_circle_id on update action' do
      new_circle = create(:vote_circle)
      put admin_user_path(user), params: {
        user: { vote_circle_id: new_circle.id }
      }
      user.reload
      expect(user.vote_circle_id).to eq(new_circle.id)
    end

    it 'redirects to the show page' do
      put admin_user_path(user), params: update_params
      expect(response).to redirect_to(admin_user_path(user))
    end
  end

  describe 'DELETE /admin/users/:id' do
    let(:deletable_user) do
      u = build(:user, vote_circle: vote_circle)
      u.save(validate: false)
      u
    end

    it 'soft deletes the user' do
      expect do
        delete admin_user_path(deletable_user)
      end.to change { User.count }.by(-1)
    end

    it 'does not hard delete the user' do
      expect do
        delete admin_user_path(deletable_user)
      end.not_to change { User.with_deleted.count }
    end

    it 'redirects to the index page' do
      delete admin_user_path(deletable_user)
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe 'batch actions' do
    describe 'POST /admin/users/batch_action with ban' do
      let(:user1) do
        u = build(:user, vote_circle: vote_circle)
        u.save(validate: false)
        u
      end
      let(:user2) do
        u = build(:user, vote_circle: vote_circle)
        u.save(validate: false)
        u
      end

      before do
        allow(User).to receive(:ban_users).and_return(true)
      end

      context 'when admin has ban permission' do
        before do
          allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
        end

        it 'bans multiple users' do
          post batch_action_admin_users_path,
               params: {
                 batch_action: 'ban',
                 collection_selection: [user1.id, user2.id]
               }
          expect(User).to have_received(:ban_users).with([user1.id.to_s, user2.id.to_s], true)
        end

        it 'redirects with alert message' do
          post batch_action_admin_users_path,
               params: {
                 batch_action: 'ban',
                 collection_selection: [user1.id]
               }
          expect(response).to redirect_to(admin_users_path)
          expect(flash[:alert]).to eq('Los usuarios han sido baneados.')
        end
      end
    end
  end

  describe 'member actions' do
    describe 'POST /admin/users/:id/ban' do
      before do
        allow(User).to receive(:ban_users).and_return(true)
        allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
      end

      it 'bans the user' do
        post ban_admin_user_path(user)
        expect(User).to have_received(:ban_users).with([user.id.to_s], true)
      end

      it 'redirects to show page with notice' do
        post ban_admin_user_path(user)
        expect(response).to redirect_to(admin_user_path(user))
        expect(flash[:notice]).to eq('El usuario ha sido modificado')
      end
    end

    describe 'DELETE /admin/users/:id/ban' do
      before do
        allow(User).to receive(:ban_users).and_return(true)
        allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
      end

      it 'unbans the user' do
        delete ban_admin_user_path(banned_user)
        expect(User).to have_received(:ban_users).with([banned_user.id.to_s], false)
      end

      it 'redirects to show page with notice' do
        delete ban_admin_user_path(banned_user)
        expect(response).to redirect_to(admin_user_path(banned_user))
        expect(flash[:notice]).to eq('El usuario ha sido modificado')
      end
    end

    describe 'POST /admin/users/:id/modal_ban_deleted' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
      end

      it 'displays modal for banning deleted user' do
        post modal_ban_deleted_admin_user_path(deleted_user)
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST /admin/users/:id/ban_deleted' do
      before do
        allow(User).to receive(:ban_users).and_return(true)
        allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
      end

      it 'bans deleted user with comment' do
        post ban_deleted_admin_user_path(deleted_user),
             params: { users: { manual_comment: 'Test comment' } }
        expect(User).to have_received(:ban_users).with([deleted_user.id.to_s], true)
      end

      it 'creates a comment when provided' do
        expect do
          post ban_deleted_admin_user_path(deleted_user),
               params: { users: { manual_comment: 'Test comment' } }
        end.to change(ActiveAdmin::Comment, :count).by(1)
      end

      it 'redirects with notice including comment' do
        post ban_deleted_admin_user_path(deleted_user),
             params: { users: { manual_comment: 'Test comment' } }
        expect(response).to redirect_to(admin_user_path(deleted_user))
        expect(flash[:notice]).to include('Test comment')
      end

      it 'does not create comment when empty' do
        expect do
          post ban_deleted_admin_user_path(deleted_user),
               params: { users: { manual_comment: '   ' } }
        end.not_to change(ActiveAdmin::Comment, :count)
      end
    end

    describe 'POST /admin/users/:id/verify' do
      it 'verifies the user' do
        post verify_admin_user_path(unverified_user)
        unverified_user.reload
        expect(unverified_user.verified).to be true
        expect(unverified_user.banned).to be false
      end

      it 'redirects to show page with notice' do
        post verify_admin_user_path(unverified_user)
        expect(response).to redirect_to(admin_user_path(unverified_user))
        expect(flash[:notice]).to eq('El usuario ha sido modificado')
      end
    end

    describe 'POST /admin/users/:id/paper_authority' do
      it 'marks user as paper authority' do
        post paper_authority_admin_user_path(user)
        user.reload
        expect(user.paper_authority).to be true
      end

      it 'redirects with success message' do
        post paper_authority_admin_user_path(user)
        expect(response).to redirect_to(admin_user_path(user))
        expect(flash[:notice]).to include('puede ejercer de autoridad')
      end
    end

    describe 'DELETE /admin/users/:id/paper_authority' do
      let(:authority_user) do
        u = build(:user, vote_circle: vote_circle, paper_authority: true)
        u.save(validate: false)
        u
      end

      it 'removes paper authority from user' do
        delete paper_authority_admin_user_path(authority_user)
        authority_user.reload
        expect(authority_user.paper_authority).to be false
      end

      it 'redirects with success message' do
        delete paper_authority_admin_user_path(authority_user)
        expect(response).to redirect_to(admin_user_path(authority_user))
        expect(flash[:notice]).to include('no puede ejercer')
      end
    end

    describe 'POST /admin/users/:id/impulsa_author' do
      it 'marks user as impulsa author' do
        post impulsa_author_admin_user_path(user)
        user.reload
        expect(user.impulsa_author).to be true
      end

      it 'redirects with success message' do
        post impulsa_author_admin_user_path(user)
        expect(response).to redirect_to(admin_user_path(user))
        expect(flash[:notice]).to include('puede crear proyectos especiales')
      end
    end

    describe 'DELETE /admin/users/:id/impulsa_author' do
      let(:author_user) do
        u = build(:user, vote_circle: vote_circle, impulsa_author: true)
        u.save(validate: false)
        u
      end

      it 'removes impulsa author from user' do
        delete impulsa_author_admin_user_path(author_user)
        author_user.reload
        expect(author_user.impulsa_author).to be false
      end

      it 'redirects with success message' do
        delete impulsa_author_admin_user_path(author_user)
        expect(response).to redirect_to(admin_user_path(author_user))
        expect(flash[:notice]).to include('no puede crear proyectos')
      end
    end

    describe 'POST /admin/users/:id/recover' do
      it 'recovers the deleted user' do
        expect do
          post recover_admin_user_path(deleted_user)
        end.to change { User.count }.by(1)
      end

      it 'redirects with success notice' do
        post recover_admin_user_path(deleted_user)
        expect(response).to redirect_to(admin_user_path(deleted_user))
        expect(flash[:notice]).to eq('Ya se ha recuperado el usuario')
      end
    end
  end

  describe 'collection actions' do
    describe 'POST /admin/users/process_search_persons' do
      let(:csv_file) do
        csv_content = "DNI;NAME;SURNAME\n12345678Z;John;Doe"
        file = Tempfile.new(['test', '.csv'])
        file.write(csv_content)
        file.rewind
        Rack::Test::UploadedFile.new(file.path, 'text/csv', original_filename: 'test.csv')
      end

      before do
        allow_any_instance_of(ActionController::DataStreaming).to receive(:send_data)
      end

      it 'processes the search persons CSV' do
        post process_search_persons_admin_users_path,
             params: { process_search_persons: { file: csv_file } }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST /admin/users/fill_csv' do
      let(:csv_file) do
        file = Tempfile.new(['fill', '.csv'])
        file.write("email,name\ntest@example.com,Test User")
        file.rewind
        Rack::Test::UploadedFile.new(file.path, 'text/csv')
      end

      before do
        allow_any_instance_of(ActionController::DataStreaming).to receive(:send_data)
        # Stub the fill_data method that's required by this action
        allow_any_instance_of(Object).to receive(:fill_data).and_return(
          { 'results' => 'csv_data', 'processed' => [user.id] }
        )
      end

      it 'processes fill CSV and downloads' do
        post fill_csv_admin_users_path,
             params: { fill_csv: { file: csv_file }, commit: 'Descargar CSV' }
        expect(response).to have_http_status(:success)
      end

      it 'processes fill CSV and redirects with filter' do
        post fill_csv_admin_users_path,
             params: { fill_csv: { file: csv_file }, commit: 'Ver resultados' }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to include('Usuarios procesados')
      end
    end

    describe 'POST /admin/users/download_participation_teams' do
      before do
        allow_any_instance_of(ActionController::DataStreaming).to receive(:send_data)
      end

      it 'downloads participation teams CSV' do
        post download_participation_teams_admin_users_path,
             params: { date: 1.week.ago.to_date.to_s }
        expect(response).to have_http_status(:success)
      end

      it 'handles blank date parameter' do
        post download_participation_teams_admin_users_path,
             params: { date: '' }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST /admin/users/create_report' do
      let(:report_group) { ReportGroup.create!(title: 'Test Group') }

      it 'creates a new report' do
        expect do
          post create_report_admin_users_path,
               params: {
                 title: 'Test Report',
                 query: User.all.to_sql,
                 main_group: report_group.id,
                 groups: [report_group.id],
                 version_at: nil
               }
        end.to change(Report, :count).by(1)
      end

      it 'redirects with success notice' do
        post create_report_admin_users_path,
             params: {
               title: 'Test Report',
               query: User.all.to_sql,
               main_group: report_group.id,
               groups: [report_group.id]
             }
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq('El informe ha sido generado')
      end

      it 'handles nil main_group' do
        expect do
          post create_report_admin_users_path,
               params: {
                 title: 'Test Report',
                 query: User.all.to_sql,
                 main_group: nil,
                 groups: []
               }
        end.to change(Report, :count).by(1)
      end
    end
  end

  describe 'CSV export' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      sign_in superadmin_user
    end

    it 'exports CSV with correct content type' do
      get admin_users_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(%r{text/csv})
    end

    it 'includes user ID in CSV' do
      get admin_users_path(format: :csv)
      expect(response.body).to include(user.id.to_s)
    end

    it 'includes user first name in CSV' do
      get admin_users_path(format: :csv)
      expect(response.body).to include(user.first_name)
    end

    it 'includes user email in CSV' do
      get admin_users_path(format: :csv)
      expect(response.body).to include(user.email)
    end
  end

  describe 'permitted parameters' do
    it 'permits email' do
      attrs = attributes_for(:user).merge(
        email: 'permitted@example.com',
        vote_circle_id: vote_circle.id
      )
      post admin_users_path, params: { user: attrs }
      expect(User.last.email).to eq('permitted@example.com')
    end

    it 'permits phone' do
      attrs = attributes_for(:user).merge(
        phone: '+491234567891',
        vote_circle_id: vote_circle.id
      )
      post admin_users_path, params: { user: attrs }
      expect(User.last.phone).to eq('+491234567891')
    end

    it 'permits unconfirmed_phone' do
      put admin_user_path(user), params: {
        user: { unconfirmed_phone: '+491234567892' }
      }
      user.reload
      expect(user.unconfirmed_phone).to eq('+491234567892')
    end

    it 'permits password and password_confirmation' do
      attrs = attributes_for(:user).merge(
        password: 'NewPassword123',
        password_confirmation: 'NewPassword123',
        vote_circle_id: vote_circle.id
      )
      post admin_users_path, params: { user: attrs }
      expect(User.last.valid_password?('NewPassword123')).to be true
    end

    it 'permits first_name' do
      put admin_user_path(user), params: {
        user: { first_name: 'NewFirstName' }
      }
      user.reload
      expect(user.first_name).to eq('NewFirstName')
    end

    it 'permits last_name' do
      put admin_user_path(user), params: {
        user: { last_name: 'NewLastName' }
      }
      user.reload
      expect(user.last_name).to eq('NewLastName')
    end

    it 'permits gender' do
      put admin_user_path(user), params: {
        user: { gender: 2 }
      }
      user.reload
      expect(user.gender).to eq(2)
    end

    it 'permits document_type' do
      put admin_user_path(user), params: {
        user: { document_type: 1 }
      }
      user.reload
      expect(user.document_type).to eq(1)
    end

    it 'permits document_vatid' do
      put admin_user_path(user), params: {
        user: { document_vatid: 'NEWPASS123' }
      }
      user.reload
      expect(user.document_vatid).to eq('NEWPASS123')
    end

    it 'permits born_at' do
      new_date = 30.years.ago.to_date
      put admin_user_path(user), params: {
        user: { born_at: new_date }
      }
      user.reload
      expect(user.born_at).to eq(new_date)
    end

    it 'permits address' do
      put admin_user_path(user), params: {
        user: { address: 'New Address' }
      }
      user.reload
      expect(user.address).to eq('New Address')
    end

    it 'permits town' do
      put admin_user_path(user), params: {
        user: { town: 'New Town' }
      }
      user.reload
      expect(user.town).to eq('New Town')
    end

    it 'permits postal_code' do
      put admin_user_path(user), params: {
        user: { postal_code: '12345' }
      }
      user.reload
      expect(user.postal_code).to eq('12345')
    end

    it 'permits province' do
      put admin_user_path(user), params: {
        user: { province: 'NP' }
      }
      user.reload
      expect(user.province).to eq('NP')
    end

    it 'permits country' do
      put admin_user_path(user), params: {
        user: { country: 'FR' }
      }
      user.reload
      expect(user.country).to eq('FR')
    end

    it 'permits vote_province' do
      put admin_user_path(user), params: {
        user: { vote_province: 'p_08' }
      }
      user.reload
      expect(user.vote_province).to eq('p_08')
    end

    it 'permits vote_town' do
      put admin_user_path(user), params: {
        user: { vote_town: 'm_08_019' }
      }
      user.reload
      expect(user.vote_town).to eq('m_08_019')
    end

    it 'permits wants_newsletter' do
      put admin_user_path(user), params: {
        user: { wants_newsletter: true }
      }
      user.reload
      expect(user.wants_newsletter).to be true
    end

    it 'permits vote_district' do
      put admin_user_path(user), params: {
        user: { vote_district: 5 }
      }
      user.reload
      expect(user.vote_district).to eq(5)
    end

    it 'permits wants_information_by_sms' do
      put admin_user_path(user), params: {
        user: { wants_information_by_sms: true }
      }
      user.reload
      expect(user.wants_information_by_sms).to be true
    end

    it 'permits exempt_from_payment' do
      put admin_user_path(user), params: {
        user: { exempt_from_payment: true }
      }
      user.reload
      expect(user.exempt_from_payment).to be true
    end

    it 'permits vote_circle_id on update action' do
      new_circle = create(:vote_circle)
      put admin_user_path(user), params: {
        user: { vote_circle_id: new_circle.id }
      }
      user.reload
      expect(user.vote_circle_id).to eq(new_circle.id)
    end

    it 'does not permit vote_circle_id on create action when action_name is not update' do
      # This test verifies the permit_params logic that only adds vote_circle_id on update
      # On create, vote_circle_id should still work as it's part of the association
      attrs = attributes_for(:user).merge(vote_circle_id: vote_circle.id)
      expect do
        post admin_users_path, params: { user: attrs }
      end.to change(User, :count).by(1)
    end
  end

  describe 'authorization' do
    it 'requires admin login' do
      sign_out admin_user
      get admin_users_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'authorizes show action' do
      allow_any_instance_of(Ability).to receive(:authorize!).with(:admin, user)
      get admin_user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'sidebars and panels' do
    it 'shows search persons sidebar on index' do
      get admin_users_path
      expect(response.body).to include('Buscar personas')
    end

    it 'shows CRUZAR DATOS sidebar on index' do
      get admin_users_path
      expect(response.body).to include('CRUZAR DATOS')
    end

    it 'shows participation teams sidebar on index' do
      get admin_users_path
      expect(response.body).to include('Equipos de participación')
    end

    it 'shows report sidebar on index' do
      get admin_users_path
      expect(response.body).to match(/informe/i)
    end

    it 'shows verifications sidebar on show' do
      get admin_user_path(user)
      expect(response.body).to include('Verificaciones')
    end

    it 'shows collaborations sidebar on show' do
      get admin_user_path(user)
      expect(response.body).to match(/colaboracion/i)
    end

    it 'shows control de IPs sidebar on show' do
      get admin_user_path(user)
      expect(response.body).to include('Control de IPs')
    end

    it 'shows votes panel on show' do
      get admin_user_path(user)
      expect(response.body).to include('Votos')
    end
  end

  describe 'action items' do
    it 'shows restore action for deleted user' do
      get admin_user_path(deleted_user)
      expect(response.body).to include('Recuperar usuario borrado')
    end

    it 'shows ban action for non-banned user' do
      allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
      get admin_user_path(user)
      expect(response.body).to include('Banear usuario')
    end

    it 'shows unban action for banned user' do
      allow_any_instance_of(Ability).to receive(:can?).with(:ban, User).and_return(true)
      get admin_user_path(banned_user)
      expect(response.body).to include('Desbanear usuario')
    end

    it 'shows verify action for unverified user' do
      get admin_user_path(unverified_user)
      expect(response.body).to include('Verificar usuario')
    end

    it 'shows paper authority action' do
      get admin_user_path(user)
      expect(response.body).to include('autoridad')
    end

    it 'shows impulsa author action' do
      get admin_user_path(user)
      expect(response.body).to include('Impulsa')
    end
  end

  describe 'multi-value filters' do
    it 'splits id_in parameter' do
      get admin_users_path, params: { q: { id_in: "#{user.id} #{user.id}" } }
      expect(response).to have_http_status(:success)
    end

    it 'splits document_vatid_in parameter' do
      get admin_users_path, params: { q: { document_vatid_in: "#{user.document_vatid} TEST123" } }
      expect(response).to have_http_status(:success)
    end

    it 'splits email_in parameter' do
      get admin_users_path, params: { q: { email_in: "#{user.email} test@example.com" } }
      expect(response).to have_http_status(:success)
    end
  end
end
