# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }
  let(:impulsa_edition_category) { create(:impulsa_edition_category, :with_votings) }
  let(:project) { create(:impulsa_project, user: user, impulsa_edition_category: impulsa_edition_category) }

  before do
    I18n.locale = :es
  end

  describe 'on_spam' do
    let(:mail) { described_class.on_spam(project) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Proyecto desestimado')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente desde el email de la edición' do
      expect(mail.from).to include(project.impulsa_edition.email)
    end

    it 'incluye mensaje sobre proyecto desestimado' do
      expect(mail.body.encoded).to match(/desestimado|vacío/)
    end

    it 'incluye email de la edición' do
      expect(mail.body.encoded).to include(project.impulsa_edition.email)
    end
  end

  describe 'on_fixes' do
    let(:mail) { described_class.on_fixes(project) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Necesaria subsanación')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente desde el email de la edición' do
      expect(mail.from).to include(project.impulsa_edition.email)
    end

    it 'incluye mensaje sobre subsanación' do
      expect(mail.body.encoded).to match(/subsanación|correcciones/)
    end

    it 'incluye email de la edición' do
      expect(mail.body.encoded).to include(project.impulsa_edition.email)
    end

    it 'incluye fecha límite para subsanación' do
      expect(mail.body.encoded).to match(/antes del/)
    end
  end

  describe 'on_validable' do
    let(:mail) { described_class.on_validable(project) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Tu proyecto ha sido revisado y está completo')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente desde el email de la edición' do
      expect(mail.from).to include(project.impulsa_edition.email)
    end

    it 'incluye mensaje sobre proyecto completo' do
      expect(mail.body.encoded).to match(/revisado|completo/)
    end
  end

  describe 'on_invalidated' do
    let(:mail) { described_class.on_invalidated(project) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Tu proyecto no ha superado la fase de evaluación')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente desde el email de la edición' do
      expect(mail.from).to include(project.impulsa_edition.email)
    end

    it 'incluye mensaje sobre no superar evaluación' do
      expect(mail.body.encoded).to match(/no ha superado|evaluación/)
    end
  end

  describe 'on_validated' do
    let(:mail) { described_class.on_validated(project) }

    it 'renderiza el asunto' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Tu proyecto ha superado la fase de evaluación')
    end

    it 'renderiza el destinatario' do
      expect(mail.to).to include(user.email)
    end

    it 'renderiza el remitente desde el email de la edición' do
      expect(mail.from).to include(project.impulsa_edition.email)
    end

    it 'incluye mensaje sobre superar evaluación' do
      expect(mail.body.encoded).to match(/ha superado|evaluación/)
    end

    it 'incluye información sobre la categoría' do
      expect(mail.body.encoded).to match(/proyecto/)
    end

    it 'si hay votaciones, incluye información sobre fechas' do
      expect(mail.body.encoded).to match(/votaciones|votar/) if project.impulsa_edition_category.has_votings
    end
  end
end
