# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaMailer, type: :mailer do
  let(:user) { create(:user, :with_dni, email: 'test@example.com') }
  let(:impulsa_edition_category) { create(:impulsa_edition_category, :with_votings) }
  let(:project) { create(:impulsa_project, user: user, impulsa_edition_category: impulsa_edition_category) }

  before do
    I18n.locale = :es
  end

  describe '#on_spam' do
    let(:mail) { described_class.on_spam(project) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Proyecto desestimado')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the edition email' do
      expect(mail.from).to eq([project.impulsa_edition.email])
    end

    it 'renders the body with rejection message' do
      expect(mail.body.encoded).to match(/desestimado|vacío/)
    end

    it 'includes the edition email in the body' do
      expect(mail.body.encoded).to include(project.impulsa_edition.email)
    end

    it 'assigns @edition_email instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'sends to the project owner' do
      expect(mail.to).to include(project.user.email)
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end
  end

  describe '#on_fixes' do
    let(:mail) { described_class.on_fixes(project) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Necesaria subsanación')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the edition email' do
      expect(mail.from).to eq([project.impulsa_edition.email])
    end

    it 'renders the body with fix requirements' do
      expect(mail.body.encoded).to match(/subsanación|correcciones/)
    end

    it 'includes the edition email in the body' do
      expect(mail.body.encoded).to include(project.impulsa_edition.email)
    end

    it 'includes the fixes deadline' do
      expect(mail.body.encoded).to match(/antes del/)
    end

    it 'assigns @fixes_limit instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @edition_email instance variable' do
      expect(mail.body.encoded).to include(project.impulsa_edition.email)
    end

    it 'assigns @project_url instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'formats the deadline date correctly' do
      deadline = project.impulsa_edition.review_projects_until.to_date - 1.second
      expect(mail.body.encoded).to be_present
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end
  end

  describe '#on_validable' do
    let(:mail) { described_class.on_validable(project) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Tu proyecto ha sido revisado y está completo')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the edition email' do
      expect(mail.from).to eq([project.impulsa_edition.email])
    end

    it 'renders the body with completion message' do
      expect(mail.body.encoded).to match(/revisado|completo/)
    end

    it 'sends to the project owner' do
      expect(mail.to).to include(project.user.email)
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end
  end

  describe '#on_invalidated' do
    let(:mail) { described_class.on_invalidated(project) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Tu proyecto no ha superado la fase de evaluación')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the edition email' do
      expect(mail.from).to eq([project.impulsa_edition.email])
    end

    it 'renders the body with invalidation message' do
      expect(mail.body.encoded).to match(/no ha superado|evaluación/)
    end

    it 'assigns @evaluation_url instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'sends to the project owner' do
      expect(mail.to).to include(project.user.email)
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end
  end

  describe '#on_validated' do
    let(:mail) { described_class.on_validated(project) }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('[PLEBISBRAND IMPULSA] Tu proyecto ha superado la fase de evaluación')
    end

    it 'sends to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'sends from the edition email' do
      expect(mail.from).to eq([project.impulsa_edition.email])
    end

    it 'renders the body with validation success message' do
      expect(mail.body.encoded).to match(/ha superado|evaluación/)
    end

    it 'includes project information' do
      expect(mail.body.encoded).to match(/proyecto/)
    end

    it 'assigns @evaluation_url instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'assigns @voting_dates when category has votings' do
      expect(mail.body.encoded).to be_present
      expect(mail.body.encoded).to match(/votaciones|votar/) if project.impulsa_edition_category.has_votings
    end

    it 'assigns @winners instance variable' do
      expect(mail.body.encoded).to be_present
    end

    it 'sends to the project owner' do
      expect(mail.to).to include(project.user.email)
    end

    it 'can be delivered' do
      expect { mail.deliver_now }.not_to raise_error
    end

    context 'when category has votings' do
      it 'includes voting information' do
        expect(mail.body.encoded).to match(/votaciones|votar/)
      end

      it 'includes voting dates' do
        expect(mail.body.encoded).to be_present
      end
    end

    context 'when category has no votings' do
      let(:category_without_votings) { create(:impulsa_edition_category, has_votings: false) }
      let(:project_no_votings) { create(:impulsa_project, user: user, impulsa_edition_category: category_without_votings) }
      let(:mail) { described_class.on_validated(project_no_votings) }

      it 'still renders successfully' do
        expect(mail.body.encoded).to be_present
      end

      it 'does not crash when no votings' do
        expect { mail.deliver_now }.not_to raise_error
      end
    end
  end

  # Edge cases and integration tests
  describe 'edge cases' do
    context 'with different user emails' do
      let(:special_user) { create(:user, :with_dni, email: 'special+impulsa@example.com') }
      let(:special_project) { create(:impulsa_project, user: special_user, impulsa_edition_category: impulsa_edition_category) }
      let(:mail) { described_class.on_spam(special_project) }

      it 'handles special characters in email' do
        expect(mail.to).to eq([special_user.email])
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'with multiple projects for same user' do
      let(:user2) { create(:user, :with_dni, email: 'user2@example.com') }
      let!(:project1) { create(:impulsa_project, user: user, impulsa_edition_category: impulsa_edition_category) }
      let!(:project2) { create(:impulsa_project, user: user2, impulsa_edition_category: impulsa_edition_category) }

      it 'sends on_spam to correct project owner' do
        mail1 = described_class.on_spam(project1)
        mail2 = described_class.on_spam(project2)

        expect(mail1.to).to eq([user.email])
        expect(mail2.to).to eq([user2.email])
      end
    end

    context 'with nil or missing edition attributes' do
      let(:project) { create(:impulsa_project, user: user, impulsa_edition_category: impulsa_edition_category) }

      it 'handles edition email gracefully' do
        expect { described_class.on_spam(project) }.not_to raise_error
      end
    end
  end

  # Test all emails can be delivered
  describe 'deliverability' do
    it 'can deliver on_spam' do
      expect { described_class.on_spam(project).deliver_now }.not_to raise_error
    end

    it 'can deliver on_fixes' do
      expect { described_class.on_fixes(project).deliver_now }.not_to raise_error
    end

    it 'can deliver on_validable' do
      expect { described_class.on_validable(project).deliver_now }.not_to raise_error
    end

    it 'can deliver on_invalidated' do
      expect { described_class.on_invalidated(project).deliver_now }.not_to raise_error
    end

    it 'can deliver on_validated' do
      expect { described_class.on_validated(project).deliver_now }.not_to raise_error
    end
  end

  # Test inheritance from ApplicationMailer
  describe 'inheritance' do
    it 'inherits from ApplicationMailer' do
      expect(described_class.superclass).to eq(ApplicationMailer)
    end
  end
end
