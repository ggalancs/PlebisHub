# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collaboration Admin', type: :request do
  let(:admin_user) { create(:user, :admin, admin: true) }
  let(:finances_admin_user) { create(:user, :admin, admin: true, finances_admin: true) }
  let!(:collaboration) { create(:collaboration, :active) }
  let!(:collaboration_bank) { create(:collaboration, :with_iban, :active) }
  let!(:collaboration_deleted) { create(:collaboration, :deleted) }

  before do
    sign_in admin_user
    # Mock helper methods and dependencies
    allow_any_instance_of(Collaboration).to receive(:get_orders).and_return([])
    allow(Collaboration).to receive(:has_bank_file?).and_return([false, false])
    allow(Order).to receive_message_chain(:banks, :by_date, :to_be_charged, :count).and_return(0)
    allow(Order).to receive_message_chain(:banks, :by_date, :charging, :count).and_return(0)
  end

  describe 'GET /admin/collaborations' do
    it 'displays the index page' do
      get admin_collaborations_path
      expect(response).to have_http_status(:success)
    end

    it 'shows collaboration IDs' do
      get admin_collaborations_path
      expect(response.body).to include(collaboration.id.to_s)
    end
  end

  describe 'scopes' do
    let!(:credit_card_collab) { create(:collaboration, payment_type: 1) }
    let!(:bank_national_collab) { create(:collaboration, :with_iban, payment_type: 3, iban_account: 'ES9121000418450200051332') }
    let!(:bank_international_collab) { create(:collaboration, :with_international_iban) }
    let!(:incomplete_collab) { create(:collaboration, :incomplete) }
    let!(:unconfirmed_collab) { create(:collaboration, :unconfirmed) }
    let!(:active_collab) { create(:collaboration, :active) }
    let!(:warning_collab) { create(:collaboration, :warning) }
    let!(:error_collab) { create(:collaboration, :error) }
    let!(:autonomy_collab) { create(:collaboration, :for_autonomy) }
    let!(:town_collab) { create(:collaboration, :for_town) }
    let!(:island_collab) { create(:collaboration, :for_island) }

    it 'filters by created scope' do
      get admin_collaborations_path(scope: 'created')
      expect(response).to have_http_status(:success)
    end

    it 'filters by credit_cards scope' do
      get admin_collaborations_path(scope: 'credit_cards')
      expect(response).to have_http_status(:success)
    end

    it 'filters by bank_nationals scope' do
      get admin_collaborations_path(scope: 'bank_nationals')
      expect(response).to have_http_status(:success)
    end

    it 'filters by bank_internationals scope' do
      get admin_collaborations_path(scope: 'bank_internationals')
      expect(response).to have_http_status(:success)
    end

    it 'filters by incomplete scope' do
      get admin_collaborations_path(scope: 'incomplete')
      expect(response).to have_http_status(:success)
    end

    it 'filters by unconfirmed scope' do
      get admin_collaborations_path(scope: 'unconfirmed')
      expect(response).to have_http_status(:success)
    end

    it 'filters by active scope' do
      get admin_collaborations_path(scope: 'active')
      expect(response).to have_http_status(:success)
    end

    it 'filters by warnings scope' do
      get admin_collaborations_path(scope: 'warnings')
      expect(response).to have_http_status(:success)
    end

    it 'filters by errors scope' do
      get admin_collaborations_path(scope: 'errors')
      expect(response).to have_http_status(:success)
    end

    it 'filters by suspects scope' do
      get admin_collaborations_path(scope: 'suspects')
      expect(response).to have_http_status(:success)
    end

    it 'filters by legacy scope' do
      get admin_collaborations_path(scope: 'legacy')
      expect(response).to have_http_status(:success)
    end

    it 'filters by non_user scope' do
      get admin_collaborations_path(scope: 'non_user')
      expect(response).to have_http_status(:success)
    end

    it 'filters by deleted scope' do
      get admin_collaborations_path(scope: 'deleted')
      expect(response).to have_http_status(:success)
    end

    it 'filters by autonomy_cc scope' do
      get admin_collaborations_path(scope: 'autonomy_cc')
      expect(response).to have_http_status(:success)
    end

    it 'filters by town_cc scope' do
      get admin_collaborations_path(scope: 'town_cc')
      expect(response).to have_http_status(:success)
    end

    it 'filters by island_cc scope' do
      get admin_collaborations_path(scope: 'island_cc')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'filters' do
    it 'filters by user_first_name' do
      get admin_collaborations_path, params: { q: { user_first_name_cont: collaboration.user.first_name } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by user_last_name' do
      get admin_collaborations_path, params: { q: { user_last_name_cont: collaboration.user.last_name } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by iban_account' do
      get admin_collaborations_path, params: { q: { iban_account_cont: collaboration_bank.iban_account } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by status' do
      get admin_collaborations_path, params: { q: { status_eq: 3 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by frequency' do
      get admin_collaborations_path, params: { q: { frequency_eq: 1 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by payment_type' do
      get admin_collaborations_path, params: { q: { payment_type_eq: 1 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by amount' do
      get admin_collaborations_path, params: { q: { amount_eq: 1000 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by created_at' do
      get admin_collaborations_path, params: { q: { created_at_gteq: 1.week.ago.to_date } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by for_autonomy_cc' do
      get admin_collaborations_path, params: { q: { for_autonomy_cc_eq: true } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by for_town_cc' do
      get admin_collaborations_path, params: { q: { for_town_cc_eq: true } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by for_island_cc' do
      get admin_collaborations_path, params: { q: { for_island_cc_eq: true } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/collaborations/:id' do
    it 'displays the show page' do
      get admin_collaboration_path(collaboration)
      expect(response).to have_http_status(:success)
    end

    it 'shows collaboration user full name' do
      get admin_collaboration_path(collaboration)
      expect(response.body).to include(collaboration.user.full_name)
    end
  end

  describe 'GET /admin/collaborations/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_collaboration_path(collaboration)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT /admin/collaborations/:id' do
    let(:update_params) do
      {
        collaboration: {
          amount: 2000,
          frequency: 3,
          for_autonomy_cc: true
        }
      }
    end

    it 'updates the collaboration' do
      put admin_collaboration_path(collaboration), params: update_params
      collaboration.reload
      expect(collaboration.amount).to eq(2000)
      expect(collaboration.frequency).to eq(3)
      expect(collaboration.for_autonomy_cc).to be true
    end

    it 'redirects to the show page' do
      put admin_collaboration_path(collaboration), params: update_params
      expect(response).to redirect_to(admin_collaboration_path(collaboration))
    end
  end

  describe 'DELETE /admin/collaborations/:id' do
    let(:deletable_collaboration) { create(:collaboration) }

    it 'soft deletes the collaboration' do
      expect do
        delete admin_collaboration_path(deletable_collaboration)
      end.to change { Collaboration.count }.by(-1)
    end

    it 'does not hard delete the collaboration' do
      expect do
        delete admin_collaboration_path(deletable_collaboration)
      end.not_to change { Collaboration.with_deleted.count }
    end

    it 'redirects to the index page' do
      delete admin_collaboration_path(deletable_collaboration)
      expect(response).to redirect_to(admin_collaborations_path)
    end
  end

  describe 'collection actions' do
    describe 'GET /admin/collaborations/charge' do
      before do
        allow(PlebisBrandCollaborationWorker).to receive(:perform_async)
        create_list(:collaboration, 3, payment_type: 1)
      end

      it 'queues charge jobs for credit cards' do
        get charge_admin_collaborations_path
        expect(PlebisBrandCollaborationWorker).to have_received(:perform_async).at_least(:once)
      end

      it 'redirects to admin collaborations' do
        get charge_admin_collaborations_path
        expect(response).to redirect_to(admin_collaborations_path)
      end
    end

    describe 'GET /admin/collaborations/generate_orders' do
      before do
        allow(PlebisBrandCollaborationWorker).to receive(:perform_async)
        create_list(:collaboration, 3, :with_iban)
      end

      it 'queues order generation jobs for banks' do
        get generate_orders_admin_collaborations_path
        expect(PlebisBrandCollaborationWorker).to have_received(:perform_async).at_least(:once)
      end

      it 'redirects to admin collaborations' do
        get generate_orders_admin_collaborations_path
        expect(response).to redirect_to(admin_collaborations_path)
      end
    end

    describe 'GET /admin/collaborations/generate_csv' do
      before do
        allow(Collaboration).to receive(:bank_file_lock)
        allow(PlebisBrandCollaborationWorker).to receive(:perform_async)
      end

      it 'locks bank file' do
        get generate_csv_admin_collaborations_path
        expect(Collaboration).to have_received(:bank_file_lock).with(true)
      end

      it 'queues CSV generation job' do
        get generate_csv_admin_collaborations_path
        expect(PlebisBrandCollaborationWorker).to have_received(:perform_async).with(-1)
      end

      it 'redirects to admin collaborations' do
        get generate_csv_admin_collaborations_path
        expect(response).to redirect_to(admin_collaborations_path)
      end
    end

    describe 'GET /admin/collaborations/download_csv' do
      context 'when file exists' do
        let(:temp_file) { Tempfile.new(['test', '.csv']) }

        before do
          temp_file.write("test,data\n")
          temp_file.rewind
          allow(Collaboration).to receive(:has_bank_file?).and_return([false, true])
          allow(Collaboration).to receive(:bank_filename).and_return(temp_file.path)
        end

        after do
          temp_file.close
          temp_file.unlink
        end

        it 'sends the file' do
          get download_csv_admin_collaborations_path
          expect(response).to have_http_status(:success)
        end
      end

      context 'when file does not exist' do
        before do
          allow(Collaboration).to receive(:has_bank_file?).and_return([false, false])
        end

        it 'shows notice and redirects' do
          get download_csv_admin_collaborations_path
          expect(flash[:notice]).to eq('El fichero no existe aún')
          expect(response).to redirect_to(admin_collaborations_path)
        end
      end
    end

    describe 'GET /admin/collaborations/mark_as_charged' do
      before do
        allow(Order).to receive(:mark_bank_orders_as_charged!)
      end

      it 'marks orders as charged for given date' do
        get mark_as_charged_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(Order).to have_received(:mark_bank_orders_as_charged!).with(Time.zone.today)
      end

      it 'redirects to admin collaborations' do
        get mark_as_charged_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to redirect_to(admin_collaborations_path)
      end
    end

    describe 'GET /admin/collaborations/mark_as_paid' do
      before do
        allow(Order).to receive(:mark_bank_orders_as_paid!)
      end

      it 'marks orders as paid for given date' do
        get mark_as_paid_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(Order).to have_received(:mark_bank_orders_as_paid!).with(Time.zone.today)
      end

      it 'redirects to admin collaborations' do
        get mark_as_paid_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to redirect_to(admin_collaborations_path)
      end
    end
  end

  describe 'member actions' do
    describe 'GET /admin/collaborations/:id/charge_order' do
      before do
        allow_any_instance_of(Collaboration).to receive(:charge!)
      end

      it 'charges the collaboration' do
        get charge_order_admin_collaboration_path(id: collaboration.id)
        expect_any_instance_of(Collaboration).to have_received(:charge!)
      end

      it 'redirects to show page' do
        get charge_order_admin_collaboration_path(id: collaboration.id)
        expect(response).to redirect_to(admin_collaboration_path(id: collaboration.id))
      end
    end

    describe 'POST /admin/collaborations/:id/recover' do
      before do
        collaboration_deleted.destroy
        allow_any_instance_of(Collaboration).to receive(:restore)
      end

      it 'restores the deleted collaboration' do
        post recover_admin_collaboration_path(id: collaboration_deleted.id)
        expect_any_instance_of(Collaboration).to have_received(:restore)
      end

      it 'shows success notice' do
        post recover_admin_collaboration_path(id: collaboration_deleted.id)
        expect(flash[:notice]).to eq('Ya se ha recuperado la colaboración.')
      end

      it 'redirects to show page' do
        post recover_admin_collaboration_path(id: collaboration_deleted.id)
        expect(response).to redirect_to(admin_collaboration_path(collaboration_deleted))
      end
    end
  end

  describe 'CSV export' do
    before do
      sign_in finances_admin_user
    end

    it 'exports CSV with correct content type' do
      get admin_collaborations_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(%r{text/csv})
    end

    it 'includes collaboration ID in CSV' do
      get admin_collaborations_path(format: :csv)
      expect(response.body).to include(collaboration.id.to_s)
    end
  end

  describe 'batch actions' do
    describe 'error_batch' do
      let!(:suspect_collab1) { create(:collaboration, :active, :with_iban) }
      let!(:suspect_collab2) { create(:collaboration, :active, :with_iban) }

      before do
        allow_any_instance_of(Collaboration).to receive(:set_error!).and_return(true)
      end

      it 'marks collaborations as errors in batch' do
        post batch_action_admin_collaborations_path,
             params: {
               batch_action: 'error_batch',
               collection_selection: [suspect_collab1.id, suspect_collab2.id],
               scope: 'suspects'
             }
        expect_any_instance_of(Collaboration).to have_received(:set_error!).at_least(:once)
      end

      it 'redirects with success notice' do
        post batch_action_admin_collaborations_path,
             params: {
               batch_action: 'error_batch',
               collection_selection: [suspect_collab1.id],
               scope: 'suspects'
             }
        expect(response).to redirect_to(admin_collaborations_path)
        expect(flash[:notice]).to eq('Las colaboraciones han sido marcadas como erróneas.')
      end
    end
  end

  describe 'territorial downloads' do
    before do
      allow(Order).to receive_message_chain(:paid, :group, :order, :pluck).and_return([])
      allow_any_instance_of(ActionController::DataStreaming).to receive(:send_data)
    end

    describe 'GET /admin/collaborations/download_for_town' do
      it 'downloads town data' do
        get download_for_town_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_autonomy' do
      it 'downloads autonomy data' do
        get download_for_autonomy_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_island' do
      it 'downloads island data' do
        get download_for_island_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_vote_circle_town' do
      it 'downloads vote circle town data' do
        get download_for_vote_circle_town_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_vote_circle_autonomy' do
      it 'downloads vote circle autonomy data' do
        get download_for_vote_circle_autonomy_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_vote_circle_island' do
      it 'downloads vote circle island data' do
        get download_for_vote_circle_island_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_circle_and_cp_town' do
      it 'downloads circle and postal code town data' do
        get download_for_circle_and_cp_town_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_circle_and_cp_autonomy' do
      it 'downloads circle and postal code autonomy data' do
        get download_for_circle_and_cp_autonomy_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /admin/collaborations/download_for_circle_and_cp_country' do
      it 'downloads circle and postal code country data' do
        get download_for_circle_and_cp_country_admin_collaborations_path, params: { date: Time.zone.today.to_s }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'permitted parameters' do
    it 'permits user_id' do
      new_user = create(:user)
      put admin_collaboration_path(collaboration), params: {
        collaboration: { user_id: new_user.id }
      }
      collaboration.reload
      expect(collaboration.user_id).to eq(new_user.id)
    end

    it 'permits status' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { status: 4 }
      }
      collaboration.reload
      expect(collaboration.status).to eq(4)
    end

    it 'permits amount' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { amount: 5000 }
      }
      collaboration.reload
      expect(collaboration.amount).to eq(5000)
    end

    it 'permits frequency' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { frequency: 12 }
      }
      collaboration.reload
      expect(collaboration.frequency).to eq(12)
    end

    it 'permits payment_type' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { payment_type: 3 }
      }
      collaboration.reload
      expect(collaboration.payment_type).to eq(3)
    end

    it 'permits for_autonomy_cc' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { for_autonomy_cc: true }
      }
      collaboration.reload
      expect(collaboration.for_autonomy_cc).to be true
    end

    it 'permits for_town_cc' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { for_town_cc: true }
      }
      collaboration.reload
      expect(collaboration.for_town_cc).to be true
    end

    it 'permits for_island_cc' do
      put admin_collaboration_path(collaboration), params: {
        collaboration: { for_island_cc: true }
      }
      collaboration.reload
      expect(collaboration.for_island_cc).to be true
    end
  end
end
