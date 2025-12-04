# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  # Mock Rails.application.secrets
  before do
    allow(Rails.application).to receive(:secrets).and_return(
      OpenStruct.new(
        default_from_email: 'test@example.com'
      )
    )
  end

  describe 'inheritance' do
    it 'inherits from ActionMailer::Base' do
      expect(described_class.superclass).to eq(ActionMailer::Base)
    end
  end

  describe 'default from address' do
    it 'sets default from address' do
      expect(described_class.default[:from]).to be_present
    end

    it 'uses either secrets or fallback' do
      from_address = described_class.default[:from]
      expect(from_address).to match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    end
  end

  describe 'subclasses' do
    it 'is inherited by CollaborationsMailer' do
      expect(CollaborationsMailer.superclass).to eq(ApplicationMailer)
    end

    it 'is inherited by ImpulsaMailer' do
      expect(ImpulsaMailer.superclass).to eq(ApplicationMailer)
    end

    it 'is inherited by UserVerificationMailer' do
      expect(UserVerificationMailer.superclass).to eq(ApplicationMailer)
    end

    it 'is inherited by UsersMailer' do
      expect(UsersMailer.superclass).to eq(ApplicationMailer)
    end
  end

  describe 'configuration' do
    it 'has a default configuration' do
      expect(described_class.default).to be_a(Hash)
    end

    it 'allows subclasses to have defaults' do
      # UsersMailer has default from configured
      expect(UsersMailer.default).to be_a(Hash)
    end
  end

  describe 'mailer methods' do
    it 'provides mail method' do
      expect(described_class.instance_methods).to include(:mail)
    end

    it 'provides headers method' do
      expect(described_class.instance_methods).to include(:headers)
    end

    it 'provides attachments method' do
      expect(described_class.instance_methods).to include(:attachments)
    end
  end
end
