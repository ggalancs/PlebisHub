# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Credential Shipment', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }
  let(:vote_circle) { create(:vote_circle) }

  before do
    sign_in admin_user
  end

  describe 'GET /admin/envios_de_credenciales' do
    context 'when there are credentials waiting to be sent' do
      before do
        user = create(:user, vote_circle: vote_circle)
        create(:user_verification, :not_sended, user: user)
      end

      it 'displays the credential shipment page' do
        get '/admin/envios_de_credenciales'
        expect(response).to have_http_status(:success)
      end

      it 'shows the count of pending credentials' do
        get '/admin/envios_de_credenciales'
        expect(response.body).to include('credenciales esperando')
      end

      it 'displays the generate shipment form' do
        get '/admin/envios_de_credenciales'
        expect(response.body).to include('Generar')
      end
    end

    context 'when there are no credentials waiting' do
      it 'displays message for no pending credentials' do
        get '/admin/envios_de_credenciales'
        expect(response).to have_http_status(:success)
        expect(response.body).to include('no hay credenciales esperando')
      end
    end
  end

  describe 'GET /admin/envios_de_credenciales/generate_shipment' do
    let!(:user) do
      create(:user,
             first_name: 'Juan',
             last_name: 'Pérez',
             address: 'Calle Test 123',
             postal_code: '28001',
             phone: '666777888',
             born_at: Date.new(1990, 5, 15),
             vote_circle: vote_circle)
    end
    let!(:verification) { create(:user_verification, :not_sended, user: user, born_at: user.born_at) }

    it 'generates CSV file with credential data' do
      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/tsv')
    end

    it 'includes user information in CSV' do
      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      csv_content = response.body
      expect(csv_content).to include('Juan')
      expect(csv_content).to include('Pérez')
      expect(csv_content).to include('Calle Test 123')
    end

    it 'updates verification with born_at date' do
      expect {
        get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      }.to change { verification.reload.born_at }
    end

    it 'generates credential code for each user' do
      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      expect(response.body).to match(/[A-Z0-9]{4}-[A-Z0-9]{4}/)
    end

    it 'respects max_reg parameter' do
      5.times do |i|
        u = create(:user, vote_circle: vote_circle, email: "user#{i}@example.com")
        create(:user_verification, :not_sended, user: u, born_at: Date.new(1990, 1, 1))
      end

      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 2 }
      lines = response.body.split("\n")
      expect(lines.length).to eq(3) # Header + 2 data rows
    end

    it 'orders verifications by created_at ASC' do
      old_verification = create(:user_verification, :not_sended,
                                 user: create(:user, vote_circle: vote_circle, email: 'old@test.com'),
                                 created_at: 2.days.ago)
      new_verification = create(:user_verification, :not_sended,
                                 user: create(:user, vote_circle: vote_circle, email: 'new@test.com'),
                                 created_at: 1.day.ago)

      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      lines = response.body.split("\n")
      first_data_row = lines[1]
      expect(first_data_row).to include(old_verification.user_id.to_s)
    end

    it 'includes all required columns in header' do
      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      header = response.body.split("\n").first
      expect(header).to include('Id')
      expect(header).to include('Nombre y Apellidos')
      expect(header).to include('Dirección')
      expect(header).to include('Código Postal')
      expect(header).to include('Municipio')
      expect(header).to include('Provincia')
      expect(header).to include('Teléfono')
      expect(header).to include('Código Credencial')
    end

    it 'capitalizes names' do
      user.update(first_name: 'juan', last_name: 'pérez')
      get '/admin/envios_de_credenciales/generate_shipment', params: { max_reg: 10 }
      expect(response.body).to include('Juan')
      expect(response.body).to include('Pérez')
    end
  end

  describe 'breadcrumb' do
    it 'displays correct breadcrumb' do
      get '/admin/envios_de_credenciales'
      expect(response.body).to include('Envíos de Credenciales')
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      let(:regular_user) { create(:user, vote_circle: vote_circle) }

      before do
        sign_out admin_user
        sign_in regular_user
      end

      it 'redirects unauthorized users' do
        get '/admin/envios_de_credenciales'
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is verifier' do
      let(:verifier) do
        user = create(:user, vote_circle: vote_circle)
        user.update_column(:flags, user.flags | 64) # verifier flag
        user
      end

      before do
        sign_out admin_user
        sign_in verifier
      end

      it 'allows verifiers to access' do
        get '/admin/envios_de_credenciales'
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is finances_admin' do
      let(:finances_admin) do
        user = create(:user, vote_circle: vote_circle)
        user.update_column(:flags, user.flags | 8) # finances_admin flag
        user
      end

      before do
        sign_out admin_user
        sign_in finances_admin
      end

      it 'allows finances admins to access' do
        get '/admin/envios_de_credenciales'
        expect(response).to have_http_status(:success)
      end
    end
  end
end
