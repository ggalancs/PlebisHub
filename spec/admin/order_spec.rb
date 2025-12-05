# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Order Admin', type: :request do
  let(:admin_user) { create(:user, :admin, admin: true) }
  let(:finances_admin_user) { create(:user, :admin, admin: true, finances_admin: true) }
  let!(:order) { create(:order, :nueva, amount: 1000, payable_at: Time.zone.today) }
  let!(:order_paid) { create(:order, :paid, amount: 2000) }
  let!(:order_deleted) { create(:order, :deleted) }

  before do
    sign_in_admin admin_user
    # Mock helper methods to avoid dependencies
    allow_any_instance_of(Order).to receive(:generate_target_territory).and_return('Estatal')
  end

  describe 'GET /admin/orders' do
    it 'displays the index page' do
      get admin_orders_path
      expect(response).to have_http_status(:success)
    end

    it 'shows order IDs' do
      get admin_orders_path
      expect(response.body).to include(order.id.to_s)
    end

    it 'shows order status' do
      get admin_orders_path
      expect(response.body).to include('Nueva')
    end

    it 'shows order amount' do
      get admin_orders_path
      # Amount is shown in euros (1000 cents = 10.00 EUR)
      expect(response.body).to match(/10[,.]00/)
    end
  end

  describe 'scopes' do
    let!(:to_be_paid_order) { create(:order, :nueva) }
    let!(:paid_order) { create(:order, :ok) }
    let!(:warning_order) { create(:order, :alerta) }
    let!(:error_order) { create(:order, :error) }
    let!(:returned_order) { create(:order, :devuelta) }
    let!(:deleted_order2) { create(:order, :deleted) }

    it 'filters by to_be_paid scope' do
      get admin_orders_path(scope: 'to_be_paid')
      expect(response).to have_http_status(:success)
    end

    it 'filters by paid scope' do
      get admin_orders_path(scope: 'paid')
      expect(response).to have_http_status(:success)
    end

    it 'filters by warnings scope' do
      get admin_orders_path(scope: 'warnings')
      expect(response).to have_http_status(:success)
    end

    it 'filters by errors scope' do
      get admin_orders_path(scope: 'errors')
      expect(response).to have_http_status(:success)
    end

    it 'filters by returned scope' do
      get admin_orders_path(scope: 'returned')
      expect(response).to have_http_status(:success)
    end

    it 'filters by deleted scope' do
      get admin_orders_path(scope: 'deleted')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'filters' do
    let!(:order_filter_test) { create(:order, status: 2, payment_type: 1, amount: 3000, first: true) }

    it 'filters by status' do
      get admin_orders_path, params: { q: { status_eq: 2 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by payment_type' do
      get admin_orders_path, params: { q: { payment_type_eq: 1 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by amount' do
      get admin_orders_path, params: { q: { amount_eq: 3000 } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by first' do
      get admin_orders_path, params: { q: { first_eq: true } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by payable_at' do
      get admin_orders_path, params: { q: { payable_at_gteq: 1.week.ago.to_date } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by payed_at' do
      get admin_orders_path, params: { q: { payed_at_gteq: 1.week.ago.to_date } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by created_at' do
      get admin_orders_path, params: { q: { created_at_gteq: 1.week.ago.to_date } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by town_code' do
      order_with_town = create(:order, :with_territory)
      get admin_orders_path, params: { q: { town_code_eq: order_with_town.town_code } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by autonomy_code' do
      order_with_autonomy = create(:order, :with_territory)
      get admin_orders_path, params: { q: { autonomy_code_eq: order_with_autonomy.autonomy_code } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/orders/:id' do
    it 'displays the show page' do
      get admin_order_path(order)
      expect(response).to have_http_status(:success)
    end

    it 'shows order status_name' do
      get admin_order_path(order)
      expect(response.body).to include('Nueva')
    end

    it 'shows order amount' do
      get admin_order_path(order)
      expect(response.body).to match(/10[,.]00/)
    end

    it 'shows payment_type_name' do
      credit_card_order = create(:order, :credit_card)
      get admin_order_path(credit_card_order)
      expect(response.body).to include('Tarjeta')
    end

    it 'shows user link when order has user' do
      get admin_order_path(order)
      expect(response.body).to include(admin_user_path(order.user))
    end

    it 'shows parent information' do
      get admin_order_path(order)
      expect(response.body).to include(order.parent_type)
    end

    it 'shows reference' do
      order_with_ref = create(:order, reference: 'TEST-REF-123')
      get admin_order_path(order_with_ref)
      expect(response.body).to include('TEST-REF-123')
    end

    it 'shows payment_identifier' do
      cc_order = create(:order, :credit_card, payment_identifier: '999999999R')
      get admin_order_path(cc_order)
      expect(response.body).to include('999999999R')
    end

    it 'shows first flag' do
      first_order = create(:order, first: true)
      get admin_order_path(first_order)
      expect(response.body).to include('true')
    end

    it 'shows payable_at date' do
      get admin_order_path(order)
      expect(response.body).to include(order.payable_at.to_s)
    end

    it 'shows payed_at date for paid orders' do
      get admin_order_path(order_paid)
      expect(response.body).to include(order_paid.payed_at.to_s(:db))
    end

    it 'shows deleted_at for deleted orders' do
      get admin_order_path(order_deleted)
      expect(response.body).to include(order_deleted.deleted_at.to_s(:db))
    end

    it 'shows town_code' do
      order_with_town = create(:order, :with_territory)
      get admin_order_path(order_with_town)
      expect(response.body).to include(order_with_town.town_code)
    end

    it 'shows autonomy_code' do
      order_with_autonomy = create(:order, :with_territory)
      get admin_order_path(order_with_autonomy)
      expect(response.body).to include(order_with_autonomy.autonomy_code)
    end
  end

  describe 'GET /admin/orders/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_order_path(order)
      expect(response).to have_http_status(:success)
    end

    it 'includes status select with all statuses' do
      get edit_admin_order_path(order)
      Order::STATUS.each_key do |status_name|
        expect(response.body).to include(status_name)
      end
    end

    it 'includes payment_type radio buttons' do
      get edit_admin_order_path(order)
      Order::PAYMENT_TYPES.each_key do |payment_type_name|
        expect(response.body).to include(payment_type_name)
      end
    end

    it 'includes amount field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[amount]')
    end

    it 'includes reference field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[reference]')
    end

    it 'includes first checkbox' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[first]')
    end

    it 'includes payment_identifier field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[payment_identifier]')
    end

    it 'includes payment_response field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[payment_response]')
    end

    it 'includes payable_at field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[payable_at]')
    end

    it 'includes payed_at field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[payed_at]')
    end

    it 'includes created_at field' do
      get edit_admin_order_path(order)
      expect(response.body).to include('order[created_at]')
    end
  end

  describe 'PUT /admin/orders/:id' do
    let(:update_params) do
      {
        order: {
          status: 2,
          reference: 'Updated Reference',
          amount: 5000,
          first: true,
          payment_type: 3
        }
      }
    end

    it 'updates the order' do
      put admin_order_path(order), params: update_params
      order.reload
      expect(order.status).to eq(2)
      expect(order.reference).to eq('Updated Reference')
      expect(order.amount).to eq(5000)
      expect(order.first).to be true
      expect(order.payment_type).to eq(3)
    end

    it 'redirects to the show page' do
      put admin_order_path(order), params: update_params
      expect(response).to redirect_to(admin_order_path(order))
    end

    it 'updates payment_identifier' do
      put admin_order_path(order), params: {
        order: { payment_identifier: 'NEW-IDENTIFIER' }
      }
      order.reload
      expect(order.payment_identifier).to eq('NEW-IDENTIFIER')
    end

    it 'updates payment_response' do
      put admin_order_path(order), params: {
        order: { payment_response: '{"test": "response"}' }
      }
      order.reload
      expect(order.payment_response).to eq('{"test": "response"}')
    end

    it 'updates payable_at' do
      new_date = 1.month.from_now.to_date
      put admin_order_path(order), params: {
        order: { payable_at: new_date }
      }
      order.reload
      expect(order.payable_at).to eq(new_date)
    end

    it 'updates payed_at' do
      new_date = 1.day.ago
      put admin_order_path(order), params: {
        order: { payed_at: new_date }
      }
      order.reload
      expect(order.payed_at.to_date).to eq(new_date.to_date)
    end

    it 'updates created_at' do
      new_date = 2.weeks.ago
      put admin_order_path(order), params: {
        order: { created_at: new_date }
      }
      order.reload
      expect(order.created_at.to_date).to eq(new_date.to_date)
    end
  end

  describe 'DELETE /admin/orders/:id' do
    let(:deletable_order) { create(:order) }

    it 'soft deletes the order' do
      expect do
        delete admin_order_path(deletable_order)
      end.to change { Order.count }.by(-1)
    end

    it 'does not hard delete the order' do
      expect do
        delete admin_order_path(deletable_order)
      end.not_to change { Order.with_deleted.count }
    end

    it 'redirects to the index page' do
      delete admin_order_path(deletable_order)
      expect(response).to redirect_to(admin_orders_path)
    end
  end

  describe 'member actions' do
    describe 'GET /admin/orders/:id/return_order' do
      let(:paid_order) { create(:order, :ok) }

      before do
        allow_any_instance_of(Order).to receive(:is_paid?).and_return(true)
        allow_any_instance_of(Order).to receive(:processed!).and_return(true)
      end

      it 'processes the paid order' do
        get return_order_admin_order_path(id: paid_order.id)
        expect_any_instance_of(Order).to have_received(:processed!)
      end

      it 'redirects to show page' do
        get return_order_admin_order_path(id: paid_order.id)
        expect(response).to redirect_to(admin_order_path(id: paid_order.id))
      end

      it 'does not process non-paid orders' do
        unpaid_order = create(:order, :nueva)
        allow_any_instance_of(Order).to receive(:is_paid?).and_return(false)
        get return_order_admin_order_path(id: unpaid_order.id)
        expect_any_instance_of(Order).not_to have_received(:processed!)
      end
    end

    describe 'POST /admin/orders/:id/recover' do
      before do
        order_deleted.destroy
        allow_any_instance_of(Order).to receive(:restore)
      end

      it 'restores the deleted order' do
        post recover_admin_order_path(id: order_deleted.id)
        expect_any_instance_of(Order).to have_received(:restore)
      end

      it 'shows success notice' do
        post recover_admin_order_path(id: order_deleted.id)
        expect(flash[:notice]).to eq('Ya se ha recuperado la orden')
      end

      it 'redirects to show page' do
        post recover_admin_order_path(id: order_deleted.id)
        expect(response).to redirect_to(admin_order_path(order_deleted))
      end
    end
  end

  describe 'action items' do
    describe 'return_order action item' do
      let(:paid_order) { create(:order, :ok) }

      it 'shows return_order link for paid orders' do
        get admin_order_path(paid_order)
        expect(response.body).to include('Orden devuelta')
      end

      it 'includes confirmation dialog' do
        get admin_order_path(paid_order)
        expect(response.body).to include('no será contabilizada como cobrada')
      end
    end

    describe 'restore_order action item' do
      it 'shows restore link for deleted orders' do
        get admin_order_path(order_deleted)
        expect(response.body).to include('Recuperar orden borrada')
      end

      it 'includes confirmation dialog' do
        get admin_order_path(order_deleted)
        expect(response.body).to include('querer recuperar esta order')
      end
    end
  end

  describe 'CSV export' do
    let!(:csv_order) { create(:order, :ok, :with_territory, amount: 1500) }

    before do
      sign_in finances_admin_user
      allow_any_instance_of(Order).to receive(:generate_target_territory).and_return('Estatal')
      allow_any_instance_of(Order).to receive(:island_code).and_return(nil)
      allow_any_instance_of(Order).to receive(:town_code).and_return('m_28_079_6')
      allow_any_instance_of(Order).to receive(:autonomy_code).and_return('c_01')
    end

    it 'exports CSV with correct content type' do
      get admin_orders_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(%r{text/csv})
    end

    it 'includes order ID in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include(csv_order.id.to_s)
    end

    it 'includes order amount in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('1500')
    end

    it 'includes status_name in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('OK')
    end

    it 'includes payment_type_name in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('Tarjeta')
    end

    it 'includes reference in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include(csv_order.reference)
    end

    it 'includes target_territory in CSV' do
      get admin_orders_path(format: :csv)
      # CSV should include the target territory
      expect(response.body).to include('Target territory')
    end

    context 'with parent collaboration' do
      let!(:collab_order) do
        collab = create(:collaboration, :active, frequency: 1)
        create(:order, :ok, parent: collab, user: collab.user)
      end

      before do
        allow_any_instance_of(Collaboration).to receive(:get_user).and_return(collab_order.user)
        allow_any_instance_of(User).to receive(:full_name).and_return('Test User')
        allow_any_instance_of(User).to receive(:document_vatid).and_return('12345678A')
        allow_any_instance_of(User).to receive(:address).and_return('Test Address')
        allow_any_instance_of(User).to receive(:postal_code).and_return('28001')
        allow_any_instance_of(User).to receive(:town_name).and_return('Madrid')
        allow_any_instance_of(User).to receive(:province_name).and_return('Madrid')
        allow_any_instance_of(User).to receive(:island_name).and_return(nil)
        allow_any_instance_of(User).to receive(:autonomy_name).and_return('Madrid')
        allow_any_instance_of(User).to receive(:vote_circle_id).and_return(nil)
      end

      it 'includes parent_id in CSV' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include(collab_order.parent_id.to_s)
      end

      it 'includes user full_name in CSV' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Test User')
      end

      it 'includes user document_vatid in CSV' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('12345678A')
      end

      it 'includes user address in CSV' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Test Address')
      end

      it 'includes postal_code in CSV' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('28001')
      end

      it 'includes town in CSV' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Madrid')
      end

      it 'includes frequency in CSV when monthly' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Mensual')
      end
    end

    context 'with different order types based on territory' do
      it 'exports island order type as I' do
        island_order = create(:order, :ok)
        allow_any_instance_of(Order).to receive(:island_code).and_return('i_07_001')
        get admin_orders_path(format: :csv)
        # The order_type column in CSV should be 'I' for island orders
        expect(response.body).to include(',I,')
      end

      it 'exports town order type as M' do
        town_order = create(:order, :ok, :with_territory)
        get admin_orders_path(format: :csv)
        # The order_type column in CSV should be 'M' for municipal orders
        expect(response.body).to include(',M,')
      end

      it 'exports autonomy order type as A' do
        autonomy_order = create(:order, :ok)
        allow_any_instance_of(Order).to receive(:island_code).and_return(nil)
        allow_any_instance_of(Order).to receive(:town_code).and_return(nil)
        allow_any_instance_of(Order).to receive(:autonomy_code).and_return('c_01')
        get admin_orders_path(format: :csv)
        # The order_type column in CSV should be 'A' for autonomy orders
        expect(response.body).to include(',A,')
      end

      it 'exports state order type as E' do
        state_order = create(:order, :ok)
        allow_any_instance_of(Order).to receive(:island_code).and_return(nil)
        allow_any_instance_of(Order).to receive(:town_code).and_return(nil)
        allow_any_instance_of(Order).to receive(:autonomy_code).and_return(nil)
        get admin_orders_path(format: :csv)
        # The order_type column in CSV should be 'E' for state orders
        expect(response.body).to include(',E,')
      end
    end

    context 'with credit card order' do
      let!(:cc_order) { create(:order, :ok, :credit_card, payment_identifier: '999999999R') }

      before do
        allow_any_instance_of(Order).to receive(:is_credit_card?).and_return(true)
        allow_any_instance_of(Order).to receive(:redsys_order_id).and_return('000000000001')
      end

      it 'includes redsys_id for credit card orders' do
        get admin_orders_path(format: :csv)
        expect(response.body).to include('000000000001')
      end
    end

    context 'with different frequencies' do
      it 'exports single frequency as Puntual' do
        collab = create(:collaboration, :active, frequency: 0)
        create(:order, :ok, parent: collab, user: collab.user)
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Puntual')
      end

      it 'exports quarterly frequency as Trimestral' do
        collab = create(:collaboration, :active, frequency: 3)
        create(:order, :ok, parent: collab, user: collab.user)
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Trimestral')
      end

      it 'exports annual frequency as Anual' do
        collab = create(:collaboration, :active, frequency: 12)
        create(:order, :ok, parent: collab, user: collab.user)
        get admin_orders_path(format: :csv)
        expect(response.body).to include('Anual')
      end
    end
  end

  describe 'download links' do
    context 'when user is admin and finances_admin' do
      before do
        sign_in finances_admin_user
      end

      it 'shows download links' do
        get admin_orders_path
        expect(response.body).to include('CSV')
      end
    end

    context 'when user is admin but not finances_admin' do
      it 'does not show download links' do
        get admin_orders_path
        # Download links should not be present for non-finance admins
        expect(response.body).not_to include('Download')
      end
    end
  end

  describe 'index columns' do
    it 'displays selectable column' do
      get admin_orders_path
      expect(response.body).to include('batch_action')
    end

    it 'displays id column' do
      get admin_orders_path
      expect(response.body).to include(order.id.to_s)
    end

    it 'displays status_name column' do
      get admin_orders_path
      expect(response.body).to include('Nueva')
    end

    it 'displays parent column' do
      get admin_orders_path
      expect(response.body).to include('Collaboration')
    end

    it 'displays user column with link' do
      get admin_orders_path
      expect(response.body).to include(admin_user_path(order.user))
    end

    it 'displays amount column in euros' do
      get admin_orders_path
      expect(response.body).to match(/10[,.]00/)
    end

    it 'displays payable_at column' do
      get admin_orders_path
      expect(response.body).to include(order.payable_at.to_s)
    end

    it 'displays payed_at column for paid orders' do
      get admin_orders_path
      expect(response.body).to include(order_paid.payed_at.to_s(:db))
    end
  end

  describe 'permitted parameters' do
    it 'permits status' do
      put admin_order_path(order), params: {
        order: { status: 4 }
      }
      order.reload
      expect(order.status).to eq(4)
    end

    it 'permits reference' do
      put admin_order_path(order), params: {
        order: { reference: 'NEW-REF-456' }
      }
      order.reload
      expect(order.reference).to eq('NEW-REF-456')
    end

    it 'permits amount' do
      put admin_order_path(order), params: {
        order: { amount: 7500 }
      }
      order.reload
      expect(order.amount).to eq(7500)
    end

    it 'permits first' do
      put admin_order_path(order), params: {
        order: { first: true }
      }
      order.reload
      expect(order.first).to be true
    end

    it 'permits payment_type' do
      put admin_order_path(order), params: {
        order: { payment_type: 2 }
      }
      order.reload
      expect(order.payment_type).to eq(2)
    end

    it 'permits payment_identifier' do
      put admin_order_path(order), params: {
        order: { payment_identifier: 'ID123' }
      }
      order.reload
      expect(order.payment_identifier).to eq('ID123')
    end

    it 'permits payment_response' do
      put admin_order_path(order), params: {
        order: { payment_response: 'RESPONSE' }
      }
      order.reload
      expect(order.payment_response).to eq('RESPONSE')
    end

    it 'permits payable_at' do
      new_date = 2.weeks.from_now.to_date
      put admin_order_path(order), params: {
        order: { payable_at: new_date }
      }
      order.reload
      expect(order.payable_at).to eq(new_date)
    end

    it 'permits payed_at' do
      new_date = 3.days.ago
      put admin_order_path(order), params: {
        order: { payed_at: new_date }
      }
      order.reload
      expect(order.payed_at.to_date).to eq(new_date.to_date)
    end

    it 'permits created_at' do
      new_date = 1.month.ago
      put admin_order_path(order), params: {
        order: { created_at: new_date }
      }
      order.reload
      expect(order.created_at.to_date).to eq(new_date.to_date)
    end
  end

  describe 'menu configuration' do
    it 'displays in Colaboraciones menu' do
      get admin_orders_path
      expect(response.body).to include('Colaboraciones')
    end
  end

  describe 'sort order' do
    let!(:old_order) { create(:order, updated_at: 3.days.ago) }
    let!(:new_order) { create(:order, updated_at: 1.day.ago) }

    it 'sorts by updated_at descending by default' do
      get admin_orders_path
      # Orders should be sorted by updated_at desc
      expect(response).to have_http_status(:success)
    end
  end

  describe 'scope_to configuration' do
    it 'uses full_view association method' do
      # The admin config uses scope_to with full_view
      get admin_orders_path
      expect(response).to have_http_status(:success)
    end

    it 'includes deleted orders in full_view' do
      get admin_orders_path(scope: 'deleted')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'show page attributes' do
    it 'shows error_message for failed orders' do
      error_order = create(:order, :error, payment_response: 'Error response')
      allow_any_instance_of(Order).to receive(:error_message).and_return('Test Error')
      get admin_order_path(error_order)
      expect(response.body).to include('Test Error')
    end
  end

  describe 'CSV column combinations' do
    let!(:complex_order) do
      collab = create(:collaboration, :active, frequency: 1)
      user = collab.user

      # Set up user with vote_circle
      vote_circle = double('VoteCircle',
                           id: 1,
                           original_name: 'Test Circle',
                           town_name: 'Circle Town',
                           island_name: 'Circle Island',
                           autonomy_name: 'Circle Autonomy',
                           country_name: 'ES')

      allow(user).to receive(:vote_circle_id).and_return(1)
      allow(user).to receive(:vote_circle).and_return(vote_circle)
      allow(user).to receive(:militant?).and_return(true)
      allow(collab).to receive(:get_user).and_return(user)

      create(:order, :ok, parent: collab, user: user)
    end

    before do
      sign_in finances_admin_user
      allow_any_instance_of(Collaboration).to receive(:get_user).and_return(complex_order.user)
    end

    it 'includes vote_circle in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('Test Circle')
    end

    it 'includes vote_circle_town in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('Circle Town')
    end

    it 'includes vote_circle_island in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('Circle Island')
    end

    it 'includes vote_circle_autonomy in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('Circle Autonomy')
    end

    it 'includes vote_circle_country in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('ES')
    end

    it 'includes es_militante in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('true')
    end

    it 'includes circulo in CSV' do
      get admin_orders_path(format: :csv)
      expect(response.body).to include('Test Circle')
    end
  end

  describe 'edge cases' do
    it 'handles orders without parent' do
      orphan_order = create(:order)
      orphan_order.update_column(:parent_id, nil)
      get admin_order_path(orphan_order)
      expect(response).to have_http_status(:success)
    end

    it 'handles orders without user' do
      no_user_order = create(:order)
      no_user_order.update_column(:user_id, nil)
      get admin_order_path(no_user_order)
      expect(response).to have_http_status(:success)
    end

    it 'handles orders with nil payed_at' do
      get admin_order_path(order)
      expect(response).to have_http_status(:success)
    end

    it 'handles orders with nil deleted_at' do
      get admin_order_path(order)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'integration with ActiveAdmin features' do
    it 'supports comments' do
      get admin_order_path(order)
      expect(response.body).to include('active_admin_comment')
    end

    it 'supports versioning with paper_trail' do
      # PaperTrail is configured in the model
      expect(order.class.ancestors).to include(PaperTrail::Model::InstanceMethods)
    end
  end
end
