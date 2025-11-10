# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Phase 3 PLEBIS_COLLABORATIONS Fixes', type: :model do
  describe 'MEDIUM-3: require statement uses require_relative' do
    it 'ActiveAdmin collaboration uses require_relative' do
      source = File.read(Rails.root.join('engines/plebis_collaborations/app/admin/collaboration.rb'))
      expect(source).to include("require_relative '../../../lib/collaborations_on_paper'")
      expect(source).not_to include("require 'collaborations_on_paper'")
    end
  end

  describe 'MEDIUM-2: Collaboration association naming' do
    it 'Collaboration model uses plural :orders association' do
      source = File.read(Rails.root.join('engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb'))
      expect(source).to include('has_many :orders')
      expect(source).not_to match(/has_many :order[^s]/)
    end

    it 'Collaboration responds to orders method' do
      expect(PlebisCollaborations::Collaboration.new).to respond_to(:orders)
    end

    it 'Association returns ActiveRecord::Associations::CollectionProxy' do
      collaboration = PlebisCollaborations::Collaboration.new
      expect(collaboration.orders).to be_a(ActiveRecord::Associations::CollectionProxy)
    end
  end

  describe 'Order model references' do
    it 'Order model has correct belongs_to association' do
      source = File.read(Rails.root.join('engines/plebis_collaborations/app/models/plebis_collaborations/order.rb'))
      expect(source).to include('belongs_to :collaboration')
    end
  end
end
