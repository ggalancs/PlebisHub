# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe NoticeRegistrar, type: :model do
    describe 'table name' do
      it 'uses notice_registrars table' do
        expect(NoticeRegistrar.table_name).to eq('notice_registrars')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        registrar = build(:notice_registrar)
        expect(registrar).to be_valid
      end

      it 'creates a notice registrar with all required attributes' do
        registrar = create(:notice_registrar)
        expect(registrar).to be_persisted
        expect(registrar.registration_id).to be_present
      end
    end

    describe 'instance methods' do
      it 'can be created with registration_id' do
        registrar = create(:notice_registrar, registration_id: 'TEST123')
        expect(registrar.registration_id).to eq('TEST123')
      end

      it 'can be created with status' do
        registrar = create(:notice_registrar, status: true)
        expect(registrar.status).to be true
      end
    end

    describe 'database operations' do
      it 'can save and retrieve a notice registrar' do
        registrar = create(:notice_registrar)
        found = NoticeRegistrar.find(registrar.id)
        expect(found.registration_id).to eq(registrar.registration_id)
      end

      it 'can update a notice registrar' do
        registrar = create(:notice_registrar, status: true)
        registrar.update(status: false)
        expect(registrar.reload.status).to be false
      end

      it 'can delete a notice registrar' do
        registrar = create(:notice_registrar)
        registrar.destroy
        expect(NoticeRegistrar.find_by(id: registrar.id)).to be_nil
      end
    end
  end
end
