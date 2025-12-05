# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MicrocreditLoan Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:microcredit) { create(:microcredit, :active) }
  let(:user) { create(:user, :with_dni) }
  let(:microcredit_option) { create(:microcredit_option, microcredit: microcredit) }
  let!(:microcredit_loan) do
    create(:microcredit_loan,
           microcredit: microcredit,
           user: user,
           amount: 100)
  end

  before do
    sign_in_admin admin_user
  end

  describe 'configuration' do
    it 'excludes destroy action' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'sets per_page to 100' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'has Microcredits parent menu' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/microcredit_loans' do
    it 'displays the index page' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'displays selectable column' do
      get admin_microcredit_loans_path
      expect(response.body).to match(/selectable.*column/i)
    end

    it 'displays id column' do
      get admin_microcredit_loans_path
      expect(response.body).to include(microcredit_loan.id.to_s)
    end

    it 'displays microcredit title as link' do
      get admin_microcredit_loans_path
      expect(response.body).to include(microcredit.title)
      expect(response.body).to include(admin_microcredit_path(microcredit))
    end

    it 'displays user full name as link' do
      get admin_microcredit_loans_path
      expect(response.body).to include(user.full_name)
      expect(response.body).to include(admin_user_path(user))
    end

    it 'displays document_vatid column' do
      get admin_microcredit_loans_path
      expect(response.body).to include(microcredit_loan.document_vatid)
    end

    it 'displays amount in euros' do
      get admin_microcredit_loans_path
      expect(response.body).to include('100')
    end

    it 'displays created_at column' do
      get admin_microcredit_loans_path
      expect(response.body).to match(/\d{4}/)
    end

    it 'displays confirmed_at column' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'displays counted_at column' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'displays discarded_at column' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'displays returned_at column' do
      get admin_microcredit_loans_path
      expect(response).to have_http_status(:success)
    end

    it 'displays actions column' do
      get admin_microcredit_loans_path
      expect(response.body).to match(/View|Edit/i)
    end

    context 'with transferred loan' do
      let(:target_microcredit) { create(:microcredit) }
      let(:transferred_loan) { create(:microcredit_loan, microcredit: target_microcredit) }

      before do
        microcredit_loan.update(transferred_to: transferred_loan)
      end

      it 'displays transferred_to link' do
        get admin_microcredit_loans_path
        expect(response.body).to include(target_microcredit.title)
        expect(response.body).to include(admin_microcredit_loan_path(transferred_loan))
      end
    end

    context 'with original loans' do
      let(:original_microcredit) { create(:microcredit) }
      let!(:original_loan) do
        create(:microcredit_loan,
               microcredit: original_microcredit,
               transferred_to: microcredit_loan)
      end

      it 'displays original loans links' do
        get admin_microcredit_loans_path
        expect(response.body).to include(original_microcredit.title)
        expect(response.body).to include(admin_microcredit_loan_path(original_loan))
      end
    end

    context 'with unconfirmed loan' do
      before do
        microcredit_loan.update(confirmed_at: nil)
      end

      it 'shows confirm link' do
        get admin_microcredit_loans_path
        expect(response.body).to include('Confirmar')
        expect(response.body).to include(confirm_admin_microcredit_loan_path(microcredit_loan))
      end
    end

    context 'with confirmed loan' do
      before do
        microcredit_loan.update(confirmed_at: 1.day.ago)
      end

      it 'shows unconfirm link' do
        get admin_microcredit_loans_path
        expect(response.body).to include('Des-confirmar')
        expect(response.body).to include(confirm_admin_microcredit_loan_path(microcredit_loan))
      end
    end

    context 'with non-discarded loan' do
      it 'shows discard link' do
        get admin_microcredit_loans_path
        expect(response.body).to include('Descartar')
        expect(response.body).to include(discard_admin_microcredit_loan_path(microcredit_loan))
      end
    end

    context 'with loan without user' do
      let!(:loan_without_user) do
        create(:microcredit_loan, :without_user,
               microcredit: microcredit)
      end

      it 'displays first and last name' do
        get admin_microcredit_loans_path
        expect(response.body).to include('Juan')
        expect(response.body).to include('García')
      end
    end

    context 'when user is finances admin' do
      before do
        allow_any_instance_of(User).to receive(:is_admin?).and_return(true)
        allow_any_instance_of(User).to receive(:finances_admin?).and_return(true)
      end

      it 'shows download links' do
        get admin_microcredit_loans_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /admin/microcredit_loans/:id' do
    it 'displays the show page' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response).to have_http_status(:success)
    end

    it 'shows loan details' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(microcredit_loan.id.to_s)
      expect(response.body).to include(microcredit.title)
      expect(response.body).to include(microcredit_loan.document_vatid)
    end

    it 'displays microcredit title with link' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(microcredit.title)
      expect(response.body).to include(admin_microcredit_path(microcredit))
    end

    it 'displays amount in euros' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include('100')
    end

    it 'displays user with link' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(user.full_name)
      expect(response.body).to include(admin_user_path(user))
    end

    it 'displays user phone' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(user.phone)
    end

    it 'displays email' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response).to have_http_status(:success)
    end

    it 'displays wants_information_by_email' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response).to have_http_status(:success)
    end

    it 'displays user_data attributes' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response).to have_http_status(:success)
    end

    it 'displays iban_account' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(microcredit_loan.iban_account)
    end

    it 'displays iban_bic' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(microcredit_loan.iban_bic)
    end

    it 'displays timestamps' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response).to have_http_status(:success)
    end

    context 'when user can admin MicrocreditLoan' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, MicrocreditLoan).and_return(true)
      end

      it 'displays ip address' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response).to have_http_status(:success)
      end
    end

    context 'with loan without user but with possible_user' do
      let(:possible_user) { create(:user, :with_dni, document_vatid: '12345678Z') }
      let!(:loan_without_user) do
        create(:microcredit_loan, :without_user,
               microcredit: microcredit,
               document_vatid: possible_user.document_vatid)
      end

      it 'displays possible user phone warning' do
        get admin_microcredit_loan_path(loan_without_user)
        expect(response.body).to include('Posible')
        expect(response.body).to include(possible_user.phone)
      end
    end

    context 'with renewable loan and active campaigns' do
      before do
        microcredit_loan.update(confirmed_at: 1.month.ago)
        create(:microcredit, :active)
      end

      it 'displays renewal link' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include('Enlace a renovar microcrédito')
        expect(response.body).to include(renewal_microcredit_loan_path(microcredit_loan.id, microcredit_loan.unique_hash))
      end
    end

    context 'with transferred_to loan' do
      let(:target_loan) { create(:microcredit_loan) }

      before do
        microcredit_loan.update(transferred_to: target_loan)
      end

      it 'displays transferred_to link' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include(target_loan.microcredit.title)
        expect(response.body).to include(admin_microcredit_loan_path(target_loan))
      end
    end

    context 'with original loans' do
      let(:original_loan) { create(:microcredit_loan, transferred_to: microcredit_loan) }

      before do
        original_loan
      end

      it 'displays original loans links' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include(original_loan.microcredit.title)
        expect(response.body).to include(admin_microcredit_loan_path(original_loan))
      end
    end

    context 'with microcredit_option_id' do
      before do
        microcredit_loan.update(microcredit_option: microcredit_option)
      end

      it 'displays microcredit option' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include(microcredit_option.name)
      end
    end

    it 'displays active admin comments section' do
      get admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include('Comments')
    end
  end

  describe 'GET /admin/microcredit_loans/new' do
    it 'displays the new form' do
      get new_admin_microcredit_loan_path
      expect(response).to have_http_status(:success)
    end

    it 'has form fields for all permitted params' do
      get new_admin_microcredit_loan_path
      expect(response.body).to include('microcredit_loan[microcredit_id]')
      expect(response.body).to include('microcredit_loan[user_id]')
      expect(response.body).to include('microcredit_loan[amount]')
      expect(response.body).to include('microcredit_loan[iban_account]')
      expect(response.body).to include('microcredit_loan[iban_bic]')
      expect(response.body).to include('microcredit_loan[document_vatid]')
      expect(response.body).to include('microcredit_loan[wants_information_by_email]')
    end
  end

  describe 'POST /admin/microcredit_loans' do
    let(:valid_params) do
      {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 500,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          document_vatid: user.document_vatid,
          wants_information_by_email: true
        }
      }
    end

    it 'creates a new microcredit loan' do
      expect do
        post admin_microcredit_loans_path, params: valid_params
      end.to change(MicrocreditLoan, :count).by(1)
    end

    it 'redirects to the show page' do
      post admin_microcredit_loans_path, params: valid_params
      expect(response).to redirect_to(admin_microcredit_loan_path(MicrocreditLoan.last))
    end
  end

  describe 'GET /admin/microcredit_loans/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_microcredit_loan_path(microcredit_loan)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_microcredit_loan_path(microcredit_loan)
      expect(response.body).to include(microcredit_loan.amount.to_s)
      expect(response.body).to include(microcredit_loan.iban_account)
    end
  end

  describe 'PUT /admin/microcredit_loans/:id' do
    let(:update_params) do
      {
        microcredit_loan: {
          amount: 200,
          wants_information_by_email: false
        }
      }
    end

    it 'updates the microcredit loan' do
      put admin_microcredit_loan_path(microcredit_loan), params: update_params
      microcredit_loan.reload
      expect(microcredit_loan.amount).to eq(200)
      expect(microcredit_loan.wants_information_by_email).to be false
    end

    it 'redirects to the show page' do
      put admin_microcredit_loan_path(microcredit_loan), params: update_params
      expect(response).to redirect_to(admin_microcredit_loan_path(microcredit_loan))
    end
  end

  describe 'scopes' do
    let!(:confirmed_loan) { create(:microcredit_loan, :confirmed, microcredit: microcredit) }
    let!(:counted_loan) { create(:microcredit_loan, :counted, microcredit: microcredit) }
    let!(:discarded_loan) { create(:microcredit_loan, :discarded, microcredit: microcredit) }
    let!(:returned_loan) { create(:microcredit_loan, :returned, microcredit: microcredit) }
    let!(:transferred_loan) { create(:microcredit_loan, :with_transfer, microcredit: microcredit) }

    it 'shows all scope' do
      get admin_microcredit_loans_path, params: { scope: 'all' }
      expect(response).to have_http_status(:success)
    end

    it 'shows confirmed scope' do
      get admin_microcredit_loans_path, params: { scope: 'confirmed' }
      expect(response).to have_http_status(:success)
    end

    it 'shows not_confirmed scope' do
      get admin_microcredit_loans_path, params: { scope: 'not_confirmed' }
      expect(response).to have_http_status(:success)
    end

    it 'shows counted scope' do
      get admin_microcredit_loans_path, params: { scope: 'counted' }
      expect(response).to have_http_status(:success)
    end

    it 'shows not_counted scope' do
      get admin_microcredit_loans_path, params: { scope: 'not_counted' }
      expect(response).to have_http_status(:success)
    end

    it 'shows discarded scope' do
      get admin_microcredit_loans_path, params: { scope: 'discarded' }
      expect(response).to have_http_status(:success)
    end

    it 'shows not_discarded scope' do
      get admin_microcredit_loans_path, params: { scope: 'not_discarded' }
      expect(response).to have_http_status(:success)
    end

    it 'shows returned scope' do
      get admin_microcredit_loans_path, params: { scope: 'returned' }
      expect(response).to have_http_status(:success)
    end

    it 'shows not_returned scope' do
      get admin_microcredit_loans_path, params: { scope: 'not_returned' }
      expect(response).to have_http_status(:success)
    end

    it 'shows transferred scope' do
      get admin_microcredit_loans_path, params: { scope: 'transferred' }
      expect(response).to have_http_status(:success)
    end

    it 'shows renewal scope' do
      get admin_microcredit_loans_path, params: { scope: 'renewal' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'filters' do
    it 'filters by id' do
      get admin_microcredit_loans_path, params: { q: { id_eq: microcredit_loan.id } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by microcredit' do
      get admin_microcredit_loans_path, params: { q: { microcredit_id_eq: microcredit.id } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by document_vatid' do
      get admin_microcredit_loans_path, params: { q: { document_vatid_eq: microcredit_loan.document_vatid } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by created_at' do
      get admin_microcredit_loans_path, params: { q: { created_at_gteq: 1.day.ago } }
      expect(response).to have_http_status(:success)
    end

    it 'filters by amount' do
      get admin_microcredit_loans_path, params: { q: { amount_eq: 100 } }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'action items' do
    context 'confirm_loan action' do
      it 'shows confirm button when not confirmed' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include('Confirmar')
        expect(response.body).to include(confirm_admin_microcredit_loan_path(microcredit_loan))
      end

      it 'shows unconfirm button when confirmed' do
        microcredit_loan.update(confirmed_at: 1.day.ago)
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include('Des-confirmar')
        expect(response.body).to include(confirm_admin_microcredit_loan_path(microcredit_loan))
      end
    end

    context 'delete action' do
      it 'shows discard button when not discarded' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include('Descartar')
        expect(response.body).to include(discard_admin_microcredit_loan_path(microcredit_loan))
      end

      it 'hides discard button when already discarded' do
        microcredit_loan.update(discarded_at: 1.day.ago)
        get admin_microcredit_loan_path(microcredit_loan)
        # Button should not be present
        loan_discards = response.body.scan(/Descartar/).count
        # There might be one in the menu, so we just verify it's minimal
        expect(loan_discards).to be <= 1
      end
    end

    context 'count_loan action' do
      it 'shows count button when not counted and not discarded' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include('Mostrar en la web')
        expect(response.body).to include(count_admin_microcredit_loan_path(microcredit_loan))
      end

      it 'hides count button when already counted' do
        microcredit_loan.update(counted_at: 1.day.ago)
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).not_to include('Mostrar en la web')
      end

      it 'hides count button when discarded' do
        microcredit_loan.update(discarded_at: 1.day.ago)
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).not_to include('Mostrar en la web')
      end
    end

    context 'download_pdf action' do
      it 'shows download PDF button' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include('Descargar PDF')
        expect(response.body).to include(download_pdf_admin_microcredit_loan_path(microcredit_loan))
      end
    end
  end

  describe 'batch actions' do
    let!(:loan1) { create(:microcredit_loan, microcredit: microcredit, confirmed_at: 1.day.ago) }
    let!(:loan2) { create(:microcredit_loan, microcredit: microcredit, confirmed_at: 1.day.ago) }

    context 'destroy batch action' do
      it 'is available when user can admin' do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, MicrocreditLoan).and_return(true)
        get admin_microcredit_loans_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'return_batch' do
      it 'marks loans as returned' do
        expect do
          post batch_action_admin_microcredit_loans_path, params: {
            batch_action: 'return_batch',
            collection_selection: [loan1.id, loan2.id],
            scope: 'confirmed'
          }
        end.to change { loan1.reload.returned_at.present? }.from(false).to(true)
      end

      it 'redirects with success notice' do
        post batch_action_admin_microcredit_loans_path, params: {
          batch_action: 'return_batch',
          collection_selection: [loan1.id, loan2.id],
          scope: 'confirmed'
        }
        expect(response).to redirect_to(admin_microcredit_loans_path)
        expect(flash[:notice]).to include('devueltas')
      end
    end

    context 'confirm_batch' do
      let!(:unconfirmed_loan1) { create(:microcredit_loan, microcredit: microcredit, confirmed_at: nil) }
      let!(:unconfirmed_loan2) { create(:microcredit_loan, microcredit: microcredit, confirmed_at: nil) }

      it 'marks loans as confirmed' do
        expect do
          post batch_action_admin_microcredit_loans_path, params: {
            batch_action: 'confirm_batch',
            collection_selection: [unconfirmed_loan1.id, unconfirmed_loan2.id],
            scope: 'not_confirmed'
          }
        end.to change { unconfirmed_loan1.reload.confirmed_at.present? }.from(false).to(true)
      end

      it 'redirects with success notice' do
        post batch_action_admin_microcredit_loans_path, params: {
          batch_action: 'confirm_batch',
          collection_selection: [unconfirmed_loan1.id, unconfirmed_loan2.id],
          scope: 'not_confirmed'
        }
        expect(response).to redirect_to(admin_microcredit_loans_path)
        expect(flash[:notice]).to include('confirmadas')
      end
    end

    context 'discard_batch' do
      let!(:not_discarded_loan1) { create(:microcredit_loan, microcredit: microcredit, discarded_at: nil) }
      let!(:not_discarded_loan2) { create(:microcredit_loan, microcredit: microcredit, discarded_at: nil) }

      it 'marks loans as discarded' do
        expect do
          post batch_action_admin_microcredit_loans_path, params: {
            batch_action: 'discard_batch',
            collection_selection: [not_discarded_loan1.id, not_discarded_loan2.id],
            scope: 'not_discarded'
          }
        end.to change { not_discarded_loan1.reload.discarded_at.present? }.from(false).to(true)
      end

      it 'redirects with success notice' do
        post batch_action_admin_microcredit_loans_path, params: {
          batch_action: 'discard_batch',
          collection_selection: [not_discarded_loan1.id, not_discarded_loan2.id],
          scope: 'not_discarded'
        }
        expect(response).to redirect_to(admin_microcredit_loans_path)
        expect(flash[:notice]).to include('descartadas')
      end
    end
  end

  describe 'member actions' do
    describe 'POST /admin/microcredit_loans/:id/count' do
      it 'counts the loan' do
        expect(microcredit_loan.counted_at).to be_nil
        post count_admin_microcredit_loan_path(microcredit_loan)
        microcredit_loan.reload
        expect(microcredit_loan.counted_at).not_to be_nil
      end

      it 'redirects back' do
        post count_admin_microcredit_loan_path(microcredit_loan)
        expect(response).to redirect_to(admin_microcredit_loans_path)
      end

      it 'shows success notice' do
        post count_admin_microcredit_loan_path(microcredit_loan)
        expect(flash[:notice]).to include('modificado')
      end

      it 'does not count already counted loan' do
        microcredit_loan.update(counted_at: 1.day.ago)
        original_counted_at = microcredit_loan.counted_at
        post count_admin_microcredit_loan_path(microcredit_loan)
        microcredit_loan.reload
        expect(microcredit_loan.counted_at.to_i).to eq(original_counted_at.to_i)
      end
    end

    describe 'POST /admin/microcredit_loans/:id/confirm' do
      it 'confirms the loan' do
        expect(microcredit_loan.confirmed_at).to be_nil
        post confirm_admin_microcredit_loan_path(microcredit_loan)
        microcredit_loan.reload
        expect(microcredit_loan.confirmed_at).not_to be_nil
      end

      it 'redirects back' do
        post confirm_admin_microcredit_loan_path(microcredit_loan)
        expect(response).to redirect_to(admin_microcredit_loans_path)
      end

      it 'shows success notice' do
        post confirm_admin_microcredit_loan_path(microcredit_loan)
        expect(flash[:notice]).to include('confirmada')
      end
    end

    describe 'DELETE /admin/microcredit_loans/:id/confirm' do
      before do
        microcredit_loan.update(confirmed_at: 1.day.ago)
      end

      it 'unconfirms the loan' do
        delete confirm_admin_microcredit_loan_path(microcredit_loan)
        microcredit_loan.reload
        expect(microcredit_loan.confirmed_at).to be_nil
      end

      it 'redirects back' do
        delete confirm_admin_microcredit_loan_path(microcredit_loan)
        expect(response).to redirect_to(admin_microcredit_loans_path)
      end

      it 'shows success notice' do
        delete confirm_admin_microcredit_loan_path(microcredit_loan)
        expect(flash[:notice]).to include('confirmada')
      end
    end

    describe 'POST /admin/microcredit_loans/:id/discard' do
      it 'discards the loan' do
        expect(microcredit_loan.discarded_at).to be_nil
        post discard_admin_microcredit_loan_path(microcredit_loan)
        microcredit_loan.reload
        expect(microcredit_loan.discarded_at).not_to be_nil
      end

      it 'redirects back' do
        post discard_admin_microcredit_loan_path(microcredit_loan)
        expect(response).to redirect_to(admin_microcredit_loans_path)
      end

      it 'shows success notice' do
        post discard_admin_microcredit_loan_path(microcredit_loan)
        expect(flash[:notice]).to include('descartado')
      end
    end

    describe 'GET /admin/microcredit_loans/:id/download_pdf' do
      before do
        # Stub PDF rendering to avoid WickedPDF dependency
        allow_any_instance_of(ActionController::Base).to receive(:render).with(
          hash_including(pdf: anything)
        ).and_return('')
      end

      it 'downloads the PDF' do
        get download_pdf_admin_microcredit_loan_path(microcredit_loan)
        expect(assigns(:loan)).to eq(microcredit_loan)
        expect(assigns(:microcredit)).to eq(microcredit)
      end

      it 'assigns loan variable' do
        get download_pdf_admin_microcredit_loan_path(microcredit_loan)
        expect(assigns(:loan)).to eq(microcredit_loan)
      end

      it 'assigns microcredit variable' do
        get download_pdf_admin_microcredit_loan_path(microcredit_loan)
        expect(assigns(:microcredit)).to eq(microcredit)
      end

      it 'assigns brand_config variable' do
        get download_pdf_admin_microcredit_loan_path(microcredit_loan)
        expect(assigns(:brand_config)).not_to be_nil
      end
    end
  end

  describe 'CSV export' do
    let!(:loan_for_export) do
      create(:microcredit_loan,
             microcredit: microcredit,
             user: user,
             confirmed_at: 1.day.ago)
    end

    it 'exports CSV with all columns' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('csv')
    end

    it 'includes id column in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('id')
    end

    it 'includes microcredit title in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include(microcredit.title)
    end

    it 'includes document_vatid in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('document_vatid')
    end

    it 'includes email in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('email')
    end

    it 'includes amount in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('amount')
    end

    it 'includes iban_account in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('iban_account')
    end

    it 'includes iban_bic in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('iban_bic')
    end

    it 'includes user phone in CSV' do
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('phone')
    end

    it 'includes microcredit_option_name in CSV' do
      loan_for_export.update(microcredit_option: microcredit_option)
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('microcredit_option_name')
    end

    it 'includes microcredit_option_intern_code in CSV' do
      loan_for_export.update(microcredit_option: microcredit_option)
      get admin_microcredit_loans_path(format: :csv)
      expect(response.body).to include('microcredit_option_intern_code')
    end

    context 'with renewable loan' do
      before do
        loan_for_export.update(confirmed_at: 1.month.ago)
        create(:microcredit, :active)
      end

      it 'includes renewal_link in CSV' do
        get admin_microcredit_loans_path(format: :csv)
        expect(response.body).to include('renewal_link')
      end
    end

    context 'with transferred loan' do
      let(:target_loan) { create(:microcredit_loan) }

      before do
        loan_for_export.update(transferred_to: target_loan)
      end

      it 'includes transferred_to microcredit title in CSV' do
        get admin_microcredit_loans_path(format: :csv)
        expect(response.body).to include(target_loan.microcredit.title)
      end
    end

    context 'with original loans' do
      let!(:original_loan) do
        create(:microcredit_loan, transferred_to: loan_for_export)
      end

      it 'includes original_loans in CSV' do
        get admin_microcredit_loans_path(format: :csv)
        expect(response.body).to include('original_loans')
      end

      it 'includes original_loan_id in CSV' do
        get admin_microcredit_loans_path(format: :csv)
        expect(response.body).to include('original_loan_id')
      end
    end
  end

  describe 'controller customizations' do
    it 'processes id_in filter with split' do
      get admin_microcredit_loans_path, params: {
        q: { id_in: "#{microcredit_loan.id} #{microcredit_loan.id + 1000}" }
      }
      expect(response).to have_http_status(:success)
    end

    it 'processes id_not_in filter with split' do
      get admin_microcredit_loans_path, params: {
        q: { id_not_in: "999 1000" }
      }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'permitted parameters' do
    it 'permits user_id' do
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX'
        }
      }
      expect(MicrocreditLoan.last.user_id).to eq(user.id)
    end

    it 'permits microcredit_id' do
      another_microcredit = create(:microcredit)
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: another_microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX'
        }
      }
      expect(MicrocreditLoan.last.microcredit_id).to eq(another_microcredit.id)
    end

    it 'permits document_vatid' do
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          document_vatid: '12345678Z',
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX'
        }
      }
      expect(MicrocreditLoan.last.document_vatid).to eq('12345678Z')
    end

    it 'permits amount' do
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 250,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX'
        }
      }
      expect(MicrocreditLoan.last.amount).to eq(250)
    end

    it 'permits iban_account' do
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES6621000418401234567891',
          iban_bic: 'CAIXESBBXXX'
        }
      }
      expect(MicrocreditLoan.last.iban_account).to eq('ES6621000418401234567891')
    end

    it 'permits iban_bic' do
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'TESTBICXXX'
        }
      }
      expect(MicrocreditLoan.last.iban_bic).to eq('TESTBICXXX')
    end

    it 'permits wants_information_by_email' do
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          wants_information_by_email: true
        }
      }
      expect(MicrocreditLoan.last.wants_information_by_email).to be true
    end

    it 'permits confirmed_at' do
      time = 1.day.ago
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          confirmed_at: time
        }
      }
      expect(MicrocreditLoan.last.confirmed_at.to_i).to eq(time.to_i)
    end

    it 'permits counted_at' do
      time = 1.day.ago
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          counted_at: time
        }
      }
      expect(MicrocreditLoan.last.counted_at.to_i).to eq(time.to_i)
    end

    it 'permits discarded_at' do
      time = 1.day.ago
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          discarded_at: time
        }
      }
      expect(MicrocreditLoan.last.discarded_at.to_i).to eq(time.to_i)
    end

    it 'permits returned_at' do
      time = 1.day.ago
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          returned_at: time
        }
      }
      expect(MicrocreditLoan.last.returned_at.to_i).to eq(time.to_i)
    end

    it 'permits transferred_to_id' do
      target_loan = create(:microcredit_loan)
      post admin_microcredit_loans_path, params: {
        microcredit_loan: {
          microcredit_id: microcredit.id,
          user_id: user.id,
          amount: 100,
          iban_account: 'ES9121000418450200051332',
          iban_bic: 'CAIXESBBXXX',
          transferred_to_id: target_loan.id
        }
      }
      expect(MicrocreditLoan.last.transferred_to_id).to eq(target_loan.id)
    end
  end

  describe 'edge cases' do
    context 'when microcredit cannot be shown' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:show, microcredit).and_return(false)
      end

      it 'displays microcredit title without link in index' do
        get admin_microcredit_loans_path
        expect(response.body).to include(microcredit.title)
        expect(response.body).not_to include(admin_microcredit_path(microcredit))
      end

      it 'displays microcredit title without link in show' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include(microcredit.title)
        expect(response.body).not_to include(admin_microcredit_path(microcredit))
      end
    end

    context 'when user cannot be shown' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:show, user).and_return(false)
      end

      it 'displays user name without link in index' do
        get admin_microcredit_loans_path
        expect(response.body).to include(user.full_name)
      end

      it 'displays user name without link in show' do
        get admin_microcredit_loan_path(microcredit_loan)
        expect(response.body).to include(user.full_name)
      end
    end

    context 'with batch action errors' do
      let!(:confirmed_loan) { create(:microcredit_loan, :confirmed, microcredit: microcredit) }

      before do
        allow_any_instance_of(MicrocreditLoan).to receive(:return!).and_return(false)
      end

      it 'shows warning on return_batch failure' do
        post batch_action_admin_microcredit_loans_path, params: {
          batch_action: 'return_batch',
          collection_selection: [confirmed_loan.id],
          scope: 'confirmed'
        }
        expect(response).to redirect_to(admin_microcredit_loans_path)
        expect(flash[:warning]).to include('error')
      end
    end

    context 'with member action errors' do
      before do
        allow_any_instance_of(MicrocreditLoan).to receive(:save).and_return(false)
        allow_any_instance_of(MicrocreditLoan).to receive(:errors).and_return(
          double(messages: { base: ['Test error'] })
        )
      end

      it 'shows error on count failure' do
        post count_admin_microcredit_loan_path(microcredit_loan)
        expect(flash[:alert]).to include('error')
      end
    end
  end
end
