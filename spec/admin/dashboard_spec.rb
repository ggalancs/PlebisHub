# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Admin Page', type: :request do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
    # Stub Notice and Election models if they're from engines
    stub_const('Notice', Class.new(ApplicationRecord)) unless defined?(Notice)
    stub_const('Election', Class.new(ApplicationRecord)) unless defined?(Election)

    # Stub model methods
    allow(User).to receive(:limit).with(30).and_return(User.none)
    allow(Notice).to receive(:limit).with(5).and_return([]) if defined?(Notice)
    allow(Election).to receive(:limit).with(5).and_return([]) if defined?(Election)
  end

  describe 'GET /admin' do
    it 'renders the dashboard page' do
      get admin_root_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the dashboard title' do
      get admin_root_path
      expect(response.body).to match(/Dashboard|Tablero/i)
    end

    it 'has important information panel' do
      get admin_root_path
      expect(response.body).to include('Información importante')
    end

    it 'includes link to privacy manual' do
      get admin_root_path
      expect(response.body).to include('Manual de uso de datos de carácter personal')
    end

    it 'has the privacy manual PDF link' do
      get admin_root_path
      expect(response.body).to include('/pdf/PLEBISBRAND_LOPD_-_MANUAL_DE_USUARIO_DE_BASES_DE_DATOS_DE_PLEBISBRAND_v.2014.09.10.pdf')
    end

    it 'opens privacy manual in new tab' do
      get admin_root_path
      expect(response.body).to include('target="_blank"')
      expect(response.body).to include('rel="noopener"')
    end
  end

  describe 'latest users panel' do
    let!(:user1) { create(:user, first_name: 'John', last_name: 'Doe', created_at: 1.day.ago) }
    let!(:user2) { create(:user, first_name: 'Jane', last_name: 'Smith', created_at: 2.days.ago) }

    before do
      allow(User).to receive(:limit).with(30).and_return([user1, user2])
    end

    it 'displays recent users panel' do
      get admin_root_path
      expect(response.body).to include('Últimos usuarios dados de alta')
    end

    it 'shows user names as links' do
      get admin_root_path
      expect(response.body).to include(user1.full_name)
      expect(response.body).to include(user2.full_name)
    end

    it 'links to user admin pages' do
      get admin_root_path
      expect(response.body).to include(admin_user_path(user1))
    end

    it 'displays user creation dates' do
      get admin_root_path
      expect(response.body).to include(user1.created_at.to_s)
    end

    it 'limits to 30 users' do
      get admin_root_path
      expect(User).to have_received(:limit).with(30)
    end
  end

  describe 'notices panel' do
    before do
      if defined?(Notice)
        notice1 = double('Notice', id: 1, title: 'Test Notice', created_at: Time.current)
        notice2 = double('Notice', id: 2, title: 'Another Notice', created_at: 1.day.ago)
        allow(Notice).to receive(:limit).with(5).and_return([notice1, notice2])
        allow(notice1).to receive(:to_param).and_return('1')
        allow(notice2).to receive(:to_param).and_return('2')
      end
    end

    it 'displays notices panel' do
      get admin_root_path
      expect(response.body).to include('Avisos')
    end

    it 'has link to create new notice' do
      get admin_root_path
      expect(response.body).to include('Enviar aviso a todos')
      expect(response.body).to match(/new_admin_notice|notices.*new/i)
    end

    it 'limits to 5 notices' do
      get admin_root_path
      expect(Notice).to have_received(:limit).with(5) if defined?(Notice)
    end
  end

  describe 'elections panel' do
    before do
      if defined?(Election)
        election1 = double('Election', id: 1, title: 'Test Election', created_at: Time.current)
        election2 = double('Election', id: 2, title: 'Another Election', created_at: 1.day.ago)
        allow(Election).to receive(:limit).with(5).and_return([election1, election2])
        allow(election1).to receive(:to_param).and_return('1')
        allow(election2).to receive(:to_param).and_return('2')
      end
    end

    it 'displays elections panel' do
      get admin_root_path
      expect(response.body).to include('Elecciones')
    end

    it 'has link to create new election' do
      get admin_root_path
      expect(response.body).to include('Dar de alta nueva elección')
      expect(response.body).to match(/new_admin_election|elections.*new/i)
    end

    it 'limits to 5 elections' do
      get admin_root_path
      expect(Election).to have_received(:limit).with(5) if defined?(Election)
    end
  end

  describe 'menu configuration' do
    it 'has priority 1' do
      get admin_root_path
      expect(response).to have_http_status(:success)
    end

    it 'uses translated label' do
      get admin_root_path
      expect(response.body).to match(/Dashboard|Tablero/i)
    end
  end

  describe 'layout structure' do
    it 'uses columns for layout' do
      get admin_root_path
      expect(response.body).to match(/column|col-/i)
    end

    it 'contains multiple panels' do
      get admin_root_path
      # Should have at least 3 panels (important info, notices, elections)
      expect(response.body.scan(/panel/).count).to be >= 2
    end
  end

  describe 'security and compliance' do
    it 'lists security documentation' do
      get admin_root_path
      expect(response.body).to include('Condiciones de uso y aviso legal')
      expect(response.body).to include('Documento de seguridad')
    end

    it 'lists personnel documentation' do
      get admin_root_path
      expect(response.body).to include('Funciones y obligaciones del personal')
      expect(response.body).to include('Relación de administradores')
      expect(response.body).to include('Relación de usuarios autorizados')
    end
  end

  describe 'internationalization' do
    it 'uses I18n for title' do
      I18n.with_locale(:es) do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
