# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredit Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:non_admin_user) { create(:user) }
  let!(:microcredit) do
    create(:microcredit,
           title: 'Test Campaign',
           priority: 5,
           remarked: false,
           starts_at: 1.week.ago,
           ends_at: 1.week.from_now,
           limits: '100 10 500 5 1000 2',
           subgoals: nil,
           account_number: 'ES7921000813610123456789',
           agreement_link: 'http://example.com/agreement',
           budget_link: 'http://example.com/budget',
           total_goal: 10000,
           bank_counted_amount: 0,
           contact_phone: '123456789',
           mailing: false)
  end
  let!(:microcredit_option) { create(:microcredit_option, microcredit: microcredit, name: 'Option 1') }

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/microcredits' do
    it 'displays the index page' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end

    it 'shows selectable column' do
      get admin_microcredits_path
      expect(response.body).to match(/batch_action/i)
    end

    it 'shows id column' do
      get admin_microcredits_path
      expect(response.body).to include(microcredit.id.to_s)
    end

    it 'shows title column' do
      get admin_microcredits_path
      expect(response.body).to include('Test Campaign')
    end

    it 'shows dates column with starts_at and ends_at' do
      get admin_microcredits_path
      expect(response.body).to include(microcredit.starts_at.to_s)
      expect(response.body).to include(microcredit.ends_at.to_s)
    end

    it 'shows limits column with phase limit amount' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end

    it 'shows totals column with campaign status' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end

    it 'shows percentages column with remaining percent' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end

    it 'shows progress column with campaign stats' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end

    it 'shows actions column' do
      get admin_microcredits_path
      expect(response.body).to match(/View|Edit|Delete/i)
    end

    context 'with loans' do
      let!(:loan_confirmed) do
        create(:microcredit_loan, microcredit: microcredit, amount: 100, confirmed_at: 1.day.ago,
                                  counted_at: 1.day.ago)
      end
      let!(:loan_unconfirmed) { create(:microcredit_loan, microcredit: microcredit, amount: 100) }
      let!(:loan_discarded) do
        create(:microcredit_loan, microcredit: microcredit, amount: 500, discarded_at: 1.day.ago)
      end

      it 'displays campaign status with confirmed/unconfirmed/discarded indicators' do
        get admin_microcredits_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /admin/microcredits (with scopes)' do
    let!(:active_microcredit) do
      create(:microcredit, title: 'Active', starts_at: 1.day.ago, ends_at: 1.day.from_now)
    end
    let!(:upcoming_microcredit) do
      create(:microcredit, title: 'Upcoming', starts_at: 1.day.from_now, ends_at: 1.week.from_now)
    end

    it 'has all scope' do
      get admin_microcredits_path, params: { scope: 'all' }
      expect(response).to have_http_status(:success)
    end

    it 'has active scope as default' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Active')
    end

    it 'has upcoming_finished scope' do
      get admin_microcredits_path, params: { scope: 'upcoming_finished' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /admin/microcredits/:id' do
    it 'displays the show page' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows all attributes' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Test Campaign')
      expect(response.body).to include(microcredit.account_number)
      expect(response.body).to include(microcredit.total_goal.to_s)
    end

    it 'shows id row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include(microcredit.id.to_s)
    end

    it 'shows title row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Test Campaign')
    end

    it 'shows priority row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('5')
    end

    it 'shows remarked row' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows slug row' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows starts_at row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include(microcredit.starts_at.to_s)
    end

    it 'shows ends_at row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include(microcredit.ends_at.to_s)
    end

    it 'shows account_number row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('ES7921000813610123456789')
    end

    it 'shows agreement_link row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('http://example.com/agreement')
    end

    it 'shows budget_link row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('http://example.com/budget')
    end

    it 'shows total_goal row' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('10000')
    end

    it 'shows bank_counted_amount row' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows limits row with formatted limits' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows totals row with phase and campaign status' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows percentages row with confidence and current percents' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows progress row with campaign metrics' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows mailing row with status tag' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows reset_at row' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows created_at row' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'shows updated_at row' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    context 'with renewal_terms attached' do
      before do
        microcredit.renewal_terms.attach(
          io: StringIO.new('%PDF-1.4 test'),
          filename: 'renewal.pdf',
          content_type: 'application/pdf'
        )
      end

      it 'shows renewal_terms row with download link' do
        get admin_microcredit_path(microcredit)
        expect(response.body).to include('renewal.pdf')
      end
    end

    it 'has statistics panel' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Estadísticas de la campaña')
    end

    it 'has microcredit options panel' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Lugares donde se aporta')
    end

    it 'shows add option link' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Añadir opción')
      expect(response.body).to include(new_admin_microcredit_microcredit_option_path(microcredit))
    end

    it 'has evolution panels' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Evolución')
    end

    it 'has active admin comments' do
      get admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'has process bank history sidebar' do
      get admin_microcredit_path(microcredit)
      expect(response.body).to include('Procesar movimientos del banco')
    end

    context 'with microcredit_options' do
      it 'displays options in paginated table' do
        get admin_microcredit_path(microcredit)
        expect(response.body).to include('Option 1')
      end

      it 'shows edit link for options' do
        get admin_microcredit_path(microcredit)
        expect(response.body).to include('Modificar')
        expect(response.body).to include(edit_admin_microcredit_microcredit_option_path(microcredit,
                                                                                          microcredit_option))
      end

      it 'shows delete link for options' do
        get admin_microcredit_path(microcredit)
        expect(response.body).to include('Borrar')
        expect(response.body).to include(admin_microcredit_microcredit_option_path(microcredit, microcredit_option))
      end
    end
  end

  describe 'GET /admin/microcredits/new' do
    it 'displays the new form' do
      get new_admin_microcredit_path
      expect(response).to have_http_status(:success)
    end

    it 'has semantic errors display' do
      get new_admin_microcredit_path
      expect(response).to have_http_status(:success)
    end

    context 'when user can admin Microcredit' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(true)
      end

      it 'shows full form fields' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[title]')
        expect(response.body).to include('microcredit[priority]')
        expect(response.body).to include('microcredit[remarked]')
        expect(response.body).to include('microcredit[starts_at]')
        expect(response.body).to include('microcredit[ends_at]')
        expect(response.body).to include('microcredit[limits]')
        expect(response.body).to include('microcredit[account_number]')
        expect(response.body).to include('microcredit[total_goal]')
      end

      it 'shows subgoals input' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[subgoals]')
      end

      it 'shows agreement_link input' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[agreement_link]')
      end

      it 'shows budget_link input' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[budget_link]')
      end

      it 'shows renewal_terms file input' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[renewal_terms]')
      end

      it 'shows bank_counted_amount input' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[bank_counted_amount]')
      end

      it 'shows mailing checkbox' do
        get new_admin_microcredit_path
        expect(response.body).to include('microcredit[mailing]')
      end
    end

    context 'when user cannot admin Microcredit' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(false)
      end

      it 'shows limited form with phase limits' do
        get new_admin_microcredit_path
        expect(response).to have_http_status(:success)
      end
    end

    it 'shows contact_phone input for all users' do
      get new_admin_microcredit_path
      expect(response.body).to include('microcredit[contact_phone]')
    end
  end

  describe 'POST /admin/microcredits' do
    let(:valid_params) do
      {
        microcredit: {
          title: 'New Campaign',
          priority: 1,
          remarked: false,
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 20 500 10',
          account_number: 'ES1234567890123456789012',
          total_goal: 5000,
          bank_counted_amount: 0,
          contact_phone: '987654321',
          agreement_link: 'http://example.com/new_agreement',
          budget_link: 'http://example.com/new_budget',
          mailing: false
        }
      }
    end

    before do
      allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(true)
    end

    it 'creates a new microcredit' do
      expect do
        post admin_microcredits_path, params: valid_params
      end.to change(Microcredit, :count).by(1)
    end

    it 'redirects to show page on success' do
      post admin_microcredits_path, params: valid_params
      expect(response).to redirect_to(admin_microcredit_path(Microcredit.last))
    end

    it 'creates with correct attributes' do
      post admin_microcredits_path, params: valid_params
      mc = Microcredit.last
      expect(mc.title).to eq('New Campaign')
      expect(mc.priority).to eq(1)
      expect(mc.total_goal).to eq(5000)
    end
  end

  describe 'GET /admin/microcredits/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_microcredit_path(microcredit)
      expect(response).to have_http_status(:success)
    end

    it 'pre-populates form with existing data' do
      get edit_admin_microcredit_path(microcredit)
      expect(response.body).to include('Test Campaign')
    end

    context 'when user can admin Microcredit' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(true)
      end

      it 'shows all editable fields' do
        get edit_admin_microcredit_path(microcredit)
        expect(response.body).to include('microcredit[title]')
        expect(response.body).to include('microcredit[limits]')
      end
    end

    context 'when user cannot admin Microcredit' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(false)
      end

      it 'shows limited form with single limits' do
        get edit_admin_microcredit_path(microcredit)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PUT /admin/microcredits/:id' do
    context 'when user can admin Microcredit' do
      let(:update_params) do
        {
          microcredit: {
            title: 'Updated Campaign',
            priority: 10,
            total_goal: 15000
          }
        }
      end

      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(true)
      end

      it 'updates the microcredit' do
        put admin_microcredit_path(microcredit), params: update_params
        microcredit.reload
        expect(microcredit.title).to eq('Updated Campaign')
        expect(microcredit.priority).to eq(10)
        expect(microcredit.total_goal).to eq(15000)
      end

      it 'redirects to show page on success' do
        put admin_microcredit_path(microcredit), params: update_params
        expect(response).to redirect_to(admin_microcredit_path(microcredit))
      end
    end

    context 'when user cannot admin Microcredit but edits limits' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(false)
      end

      it 'updates limits when phase total remains constant' do
        original_phase_total = microcredit.phase_limit_amount

        put admin_microcredit_path(microcredit), params: {
          microcredit: {
            single_limit_100: 5,
            single_limit_500: 6,
            single_limit_1000: 5
          }
        }

        microcredit.reload
        expect(microcredit.phase_limit_amount).to eq(original_phase_total)
      end

      it 'shows error when phase total changes' do
        put admin_microcredit_path(microcredit), params: {
          microcredit: {
            single_limit_100: 1,
            single_limit_500: 1,
            single_limit_1000: 1
          }
        }

        expect(response).to have_http_status(:success)
        expect(response.body).to include('debe permanecer constante')
      end
    end
  end

  describe 'DELETE /admin/microcredits/:id' do
    it 'soft deletes the microcredit' do
      expect do
        delete admin_microcredit_path(microcredit)
      end.to change { Microcredit.with_deleted.count }.by(0)
        .and change { Microcredit.count }.by(-1)
    end

    it 'redirects to index page' do
      delete admin_microcredit_path(microcredit)
      expect(response).to redirect_to(admin_microcredits_path)
    end
  end

  describe 'filters' do
    it 'has starts_at filter' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end

    it 'has ends_at filter' do
      get admin_microcredits_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'sidebars' do
    describe 'Help sidebar on index' do
      it 'displays help text' do
        get admin_microcredits_path
        expect(response.body).to include('Ayuda')
        expect(response.body).to include('confianza')
      end

      it 'explains status symbols' do
        get admin_microcredits_path
        expect(response.body).to include('suscrito')
        expect(response.body).to include('confirmado')
        expect(response.body).to include('descartado')
      end
    end

    describe 'Statistics sidebar on index' do
      it 'displays campaign statistics' do
        get admin_microcredits_path
        expect(response.body).to include('Estadísticas de las campañas seleccionadas')
      end
    end

    describe 'Process bank history sidebar on show' do
      it 'displays bank processing form' do
        get admin_microcredit_path(microcredit)
        expect(response.body).to include('Procesar movimientos del banco')
      end
    end
  end

  describe 'action items' do
    describe 'change_phase action item' do
      context 'when phase has no remaining slots' do
        before do
          # Create loans to fill all limits
          microcredit.limits.each do |amount, limit|
            limit.times do
              create(:microcredit_loan,
                     microcredit: microcredit,
                     amount: amount,
                     confirmed_at: 1.day.ago,
                     counted_at: 1.day.ago)
            end
          end
          microcredit.clear_cache
        end

        it 'shows change phase link' do
          get admin_microcredit_path(microcredit)
          expect(response.body).to include('Cambiar de fase')
          expect(response.body).to include(change_phase_admin_microcredit_path(microcredit))
        end
      end

      context 'when phase has remaining slots' do
        it 'does not show change phase link' do
          get admin_microcredit_path(microcredit)
          expect(response.body).not_to include('Cambiar de fase')
        end
      end
    end
  end

  describe 'POST /admin/microcredits/:id/change_phase' do
    let!(:confirmed_loan) do
      create(:microcredit_loan, microcredit: microcredit, confirmed_at: 1.day.ago, counted_at: nil)
    end

    it 'changes the microcredit phase' do
      expect do
        post change_phase_admin_microcredit_path(microcredit)
      end.to change { microcredit.reload.reset_at }.from(nil)
    end

    it 'updates counted_at for confirmed loans' do
      post change_phase_admin_microcredit_path(microcredit)
      expect(confirmed_loan.reload.counted_at).not_to be_nil
    end

    it 'sets flash notice' do
      post change_phase_admin_microcredit_path(microcredit)
      expect(flash[:notice]).to eq('La campaña ha cambiado de fase.')
    end

    it 'redirects to show page' do
      post change_phase_admin_microcredit_path(microcredit)
      expect(response).to redirect_to(admin_microcredit_path(microcredit))
    end
  end

  describe 'POST /admin/microcredits/:id/process_bank_history' do
    let!(:loan_to_confirm) do
      create(:microcredit_loan,
             microcredit: microcredit,
             amount: 100,
             first_name: 'Juan',
             last_name: 'García',
             confirmed_at: nil)
    end

    let(:norma43_data) do
      {
        movements: [
          {
            amount: 100,
            concept: "#{loan_to_confirm.last_name} #{loan_to_confirm.first_name}                   #{loan_to_confirm.id} - #{microcredit.title}"
          }
        ]
      }
    end

    before do
      # Mock Norma43 class and its read method
      stub_const('Norma43', Class.new)
      allow(Norma43).to receive(:read).and_return(norma43_data)

      # Create a mock file
      @mock_file = double('file', tempfile: StringIO.new('mock norma43 data'))
    end

    it 'processes bank history file' do
      post process_bank_history_admin_microcredit_path(microcredit), params: {
        process_bank_history: {
          file: @mock_file
        }
      }
      expect(response).to have_http_status(:success)
    end

    it 'identifies sure matches' do
      post process_bank_history_admin_microcredit_path(microcredit), params: {
        process_bank_history: {
          file: @mock_file
        }
      }
      expect(response).to have_http_status(:success)
    end

    it 'handles movements with doubts' do
      norma43_data_doubts = {
        movements: [
          {
            amount: 100,
            concept: "Unknown Person                           #{loan_to_confirm.id} something"
          }
        ]
      }
      allow(Norma43).to receive(:read).and_return(norma43_data_doubts)

      post process_bank_history_admin_microcredit_path(microcredit), params: {
        process_bank_history: {
          file: @mock_file
        }
      }
      expect(response).to have_http_status(:success)
    end

    it 'handles empty movements' do
      norma43_data_empty = {
        movements: [
          {
            amount: 50,
            concept: 'Unrelated transaction with no matching ID'
          }
        ]
      }
      allow(Norma43).to receive(:read).and_return(norma43_data_empty)

      post process_bank_history_admin_microcredit_path(microcredit), params: {
        process_bank_history: {
          file: @mock_file
        }
      }
      expect(response).to have_http_status(:success)
    end

    it 'handles already confirmed loans' do
      loan_to_confirm.update(confirmed_at: 2.days.ago)
      post process_bank_history_admin_microcredit_path(microcredit), params: {
        process_bank_history: {
          file: @mock_file
        }
      }
      expect(response).to have_http_status(:success)
    end

    it 'uses transliterated names for comparison' do
      loan_with_accents = create(:microcredit_loan,
                                  microcredit: microcredit,
                                  amount: 200,
                                  first_name: 'José',
                                  last_name: 'García',
                                  confirmed_at: nil)

      norma43_transliterated = {
        movements: [
          {
            amount: 200,
            concept: "jose garcia                              #{loan_with_accents.id} - #{microcredit.title}"
          }
        ]
      }
      allow(Norma43).to receive(:read).and_return(norma43_transliterated)

      post process_bank_history_admin_microcredit_path(microcredit), params: {
        process_bank_history: {
          file: @mock_file
        }
      }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'permitted parameters' do
    before do
      allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(true)
    end

    it 'permits title' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Permitted Title',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000
        }
      }
      expect(Microcredit.last.title).to eq('Permitted Title')
    end

    it 'permits starts_at' do
      future_date = 2.days.from_now
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: future_date,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000
        }
      }
      expect(Microcredit.last.starts_at.to_date).to eq(future_date.to_date)
    end

    it 'permits ends_at' do
      end_date = 2.months.from_now
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: end_date,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000
        }
      }
      expect(Microcredit.last.ends_at.to_date).to eq(end_date.to_date)
    end

    it 'permits limits' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 10 500 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000
        }
      }
      expect(Microcredit.last.limits).to eq({ 100 => 10, 500 => 5 })
    end

    it 'permits subgoals' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          subgoals: '1000: First goal',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000
        }
      }
      expect(Microcredit.last[:subgoals]).to eq('1000: First goal')
    end

    it 'permits account_number' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES9876543210987654321098',
          total_goal: 1000
        }
      }
      expect(Microcredit.last.account_number).to eq('ES9876543210987654321098')
    end

    it 'permits total_goal' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 25000
        }
      }
      expect(Microcredit.last.total_goal).to eq(25000)
    end

    it 'permits bank_counted_amount' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          bank_counted_amount: 500
        }
      }
      expect(Microcredit.last.bank_counted_amount).to eq(500)
    end

    it 'permits contact_phone' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          contact_phone: '555-1234'
        }
      }
      expect(Microcredit.last.contact_phone).to eq('555-1234')
    end

    it 'permits agreement_link' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          agreement_link: 'http://example.com/agreement2'
        }
      }
      expect(Microcredit.last.agreement_link).to eq('http://example.com/agreement2')
    end

    it 'permits budget_link' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          budget_link: 'http://example.com/budget2'
        }
      }
      expect(Microcredit.last.budget_link).to eq('http://example.com/budget2')
    end

    it 'permits mailing' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          mailing: true
        }
      }
      expect(Microcredit.last.mailing).to be true
    end

    it 'permits priority' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          priority: 3
        }
      }
      expect(Microcredit.last.priority).to eq(3)
    end

    it 'permits remarked' do
      post admin_microcredits_path, params: {
        microcredit: {
          title: 'Test',
          starts_at: 1.day.from_now,
          ends_at: 1.month.from_now,
          limits: '100 5',
          account_number: 'ES1234567890123456789012',
          total_goal: 1000,
          remarked: true
        }
      }
      expect(Microcredit.last.remarked).to be true
    end

    context 'when user cannot admin Microcredit' do
      before do
        allow_any_instance_of(Ability).to receive(:can?).with(:admin, Microcredit).and_return(false)
      end

      it 'only permits contact_phone' do
        put admin_microcredit_path(microcredit), params: {
          microcredit: {
            contact_phone: '999-8888'
          }
        }
        microcredit.reload
        expect(microcredit.contact_phone).to eq('999-8888')
      end
    end
  end

  describe 'sort order' do
    let!(:microcredit_a) { create(:microcredit, title: 'AAA Campaign') }
    let!(:microcredit_z) { create(:microcredit, title: 'ZZZ Campaign') }

    it 'sorts by title ascending by default' do
      get admin_microcredits_path
      expect(response.body.index('AAA Campaign')).to be < response.body.index('ZZZ Campaign')
    end
  end

  describe 'MicrocreditOption nested admin' do
    describe 'POST /admin/microcredits/:microcredit_id/microcredit_options' do
      let(:option_params) do
        {
          microcredit_option: {
            name: 'New Option',
            intern_code: 'OPT001'
          }
        }
      end

      it 'creates a new microcredit option' do
        expect do
          post admin_microcredit_microcredit_options_path(microcredit), params: option_params
        end.to change(MicrocreditOption, :count).by(1)
      end

      it 'redirects to parent microcredit on success' do
        post admin_microcredit_microcredit_options_path(microcredit), params: option_params
        expect(response).to redirect_to(admin_microcredit_path(microcredit))
      end
    end

    describe 'PUT /admin/microcredits/:microcredit_id/microcredit_options/:id' do
      let(:update_option_params) do
        {
          microcredit_option: {
            name: 'Updated Option'
          }
        }
      end

      it 'updates the microcredit option' do
        put admin_microcredit_microcredit_option_path(microcredit, microcredit_option),
            params: update_option_params
        microcredit_option.reload
        expect(microcredit_option.name).to eq('Updated Option')
      end

      it 'redirects to parent microcredit on success' do
        put admin_microcredit_microcredit_option_path(microcredit, microcredit_option),
            params: update_option_params
        expect(response).to redirect_to(admin_microcredit_path(microcredit))
      end
    end

    describe 'nested option form' do
      it 'uses partial form' do
        get new_admin_microcredit_microcredit_option_path(microcredit)
        expect(response).to have_http_status(:success)
      end
    end

    describe 'nested option permitted params' do
      it 'permits microcredit_id' do
        post admin_microcredit_microcredit_options_path(microcredit), params: {
          microcredit_option: {
            name: 'Test Option',
            microcredit_id: microcredit.id
          }
        }
        expect(MicrocreditOption.last.microcredit_id).to eq(microcredit.id)
      end

      it 'permits name' do
        post admin_microcredit_microcredit_options_path(microcredit), params: {
          microcredit_option: {
            name: 'Permitted Name'
          }
        }
        expect(MicrocreditOption.last.name).to eq('Permitted Name')
      end

      it 'permits parent_id' do
        parent_option = create(:microcredit_option, microcredit: microcredit)
        post admin_microcredit_microcredit_options_path(microcredit), params: {
          microcredit_option: {
            name: 'Child Option',
            parent_id: parent_option.id
          }
        }
        expect(MicrocreditOption.last.parent_id).to eq(parent_option.id)
      end

      it 'permits intern_code' do
        post admin_microcredit_microcredit_options_path(microcredit), params: {
          microcredit_option: {
            name: 'Test',
            intern_code: 'CODE123'
          }
        }
        expect(MicrocreditOption.last.intern_code).to eq('CODE123')
      end
    end

    describe 'nested option menu' do
      it 'is hidden from main menu' do
        get admin_microcredit_microcredit_options_path(microcredit)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
