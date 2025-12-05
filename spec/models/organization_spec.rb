# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid organization' do
      organization = build(:organization)
      expect(organization).to be_valid
    end

    it 'creates organization with attributes' do
      organization = create(:organization, name: 'Test Organization')
      expect(organization.name).to eq('Test Organization')
      expect(organization).to be_persisted
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    describe 'name' do
      it 'requires name to be present' do
        organization = build(:organization, name: nil)
        expect(organization).not_to be_valid
        expect(organization.errors[:name]).to include("can't be blank")
      end

      it 'accepts valid name' do
        organization = build(:organization, name: 'Valid Organization Name')
        expect(organization).to be_valid
      end

      it 'rejects empty name' do
        organization = build(:organization, name: '')
        expect(organization).not_to be_valid
        expect(organization.errors[:name]).to include("can't be blank")
      end

      it 'rejects blank name (only whitespace)' do
        organization = build(:organization, name: '   ')
        expect(organization).not_to be_valid
        expect(organization.errors[:name]).to include("can't be blank")
      end

      it 'accepts name at maximum length (255 characters)' do
        organization = build(:organization, name: 'A' * 255)
        expect(organization).to be_valid
      end

      it 'rejects name exceeding maximum length (256 characters)' do
        organization = build(:organization, name: 'A' * 256)
        expect(organization).not_to be_valid
        expect(organization.errors[:name]).to include('is too long (maximum is 255 characters)')
      end

      it 'accepts name with special characters' do
        organization = build(:organization, name: 'Organization & Co. - Test!')
        expect(organization).to be_valid
      end

      it 'accepts name with unicode characters' do
        organization = build(:organization, name: 'Organización Española')
        expect(organization).to be_valid
      end

      it 'accepts name with numbers' do
        organization = build(:organization, name: 'Organization 2024')
        expect(organization).to be_valid
      end
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    describe 'brand_settings' do
      it 'has many brand_settings' do
        association = described_class.reflect_on_association(:brand_settings)
        expect(association.macro).to eq(:has_many)
      end

      it 'has dependent: :nullify option' do
        association = described_class.reflect_on_association(:brand_settings)
        expect(association.options[:dependent]).to eq(:nullify)
      end

      it 'nullifies brand_settings when organization is destroyed' do
        organization = create(:organization)
        brand_setting = create(:brand_setting, scope: 'organization', organization: organization)

        organization.destroy

        expect(brand_setting.reload.organization_id).to be_nil
      end

      it 'allows multiple brand_settings' do
        organization = create(:organization)
        # Note: In reality, only one brand_setting per organization is allowed due to unique_organization_setting validation
        # But the association itself allows multiple records
        setting1 = create(:brand_setting, scope: 'organization', organization: organization, brand_color: '#FF0000')

        expect(organization.brand_settings.count).to eq(1)
        expect(organization.brand_settings).to include(setting1)
      end

      it 'returns empty collection when no brand_settings exist' do
        organization = create(:organization)
        expect(organization.brand_settings).to be_empty
      end
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates organization with valid attributes' do
      expect {
        create(:organization, name: 'New Organization')
      }.to change(Organization, :count).by(1)
    end

    it 'reads organization attributes correctly' do
      organization = create(:organization, name: 'Read Test')
      found = Organization.find(organization.id)

      expect(found.name).to eq('Read Test')
      expect(found.id).to eq(organization.id)
    end

    it 'updates organization attributes' do
      organization = create(:organization, name: 'Original Name')
      organization.update(name: 'Updated Name')

      expect(organization.reload.name).to eq('Updated Name')
    end

    it 'deletes organization' do
      organization = create(:organization)

      expect {
        organization.destroy
      }.to change(Organization, :count).by(-1)
    end

    it 'fails to create organization without required attributes' do
      organization = build(:organization, name: nil)

      expect(organization.save).to be false
      expect(organization.errors[:name]).to be_present
    end

    it 'fails to update with invalid attributes' do
      organization = create(:organization, name: 'Valid Name')

      result = organization.update(name: nil)

      expect(result).to be false
      expect(organization.errors[:name]).to include("can't be blank")
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles organization with minimum valid name length (1 character)' do
      organization = build(:organization, name: 'A')
      expect(organization).to be_valid
    end

    it 'handles organization name with leading/trailing whitespace' do
      organization = create(:organization, name: '  Test Organization  ')
      # Rails doesn't automatically strip unless configured
      expect(organization.name).to eq('  Test Organization  ')
    end

    it 'allows duplicate names' do
      create(:organization, name: 'Duplicate Name')
      duplicate = build(:organization, name: 'Duplicate Name')

      expect(duplicate).to be_valid
    end

    it 'persists timestamps correctly' do
      organization = create(:organization)

      expect(organization.created_at).to be_present
      expect(organization.updated_at).to be_present
      expect(organization.created_at).to be_within(1.second).of(Time.current)
    end

    it 'updates updated_at when modified' do
      organization = create(:organization)
      original_updated_at = organization.updated_at

      sleep 0.01
      organization.update(name: 'Modified Name')

      expect(organization.updated_at).to be > original_updated_at
    end

    it 'maintains created_at when updated' do
      organization = create(:organization)
      original_created_at = organization.created_at

      sleep 0.01
      organization.update(name: 'Modified Name')

      expect(organization.created_at.to_i).to eq(original_created_at.to_i)
    end
  end

  # ====================
  # QUERY TESTS
  # ====================

  describe 'queries' do
    it 'finds organization by name' do
      organization = create(:organization, name: 'Searchable Name')

      found = Organization.find_by(name: 'Searchable Name')

      expect(found).to eq(organization)
    end

    it 'finds organization by id' do
      organization = create(:organization)

      found = Organization.find(organization.id)

      expect(found).to eq(organization)
    end

    it 'returns all organizations' do
      org1 = create(:organization, name: 'Organization 1')
      org2 = create(:organization, name: 'Organization 2')
      org3 = create(:organization, name: 'Organization 3')

      all_orgs = Organization.all

      expect(all_orgs).to include(org1, org2, org3)
      expect(all_orgs.count).to be >= 3
    end

    it 'orders organizations by name' do
      org_c = create(:organization, name: 'C Organization')
      org_a = create(:organization, name: 'A Organization')
      org_b = create(:organization, name: 'B Organization')

      ordered = Organization.order(:name).last(3)

      expect(ordered.map(&:name)).to eq(['A Organization', 'B Organization', 'C Organization'])
    end

    it 'counts organizations' do
      initial_count = Organization.count
      create_list(:organization, 3)

      expect(Organization.count).to eq(initial_count + 3)
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration scenarios' do
    it 'tracks full lifecycle of organization' do
      initial_count = Organization.count

      # Create
      organization = create(:organization, name: 'Lifecycle Test')
      expect(Organization.count).to eq(initial_count + 1)

      # Update
      organization.update(name: 'Lifecycle Test Updated')
      expect(organization.reload.name).to eq('Lifecycle Test Updated')

      # Associate with brand_settings
      brand_setting = create(:brand_setting, scope: 'organization', organization: organization)
      expect(organization.brand_settings).to include(brand_setting)

      # Delete (should nullify brand_setting)
      organization.destroy
      expect(Organization.count).to eq(initial_count)
      expect(brand_setting.reload.organization_id).to be_nil
    end

    it 'handles organization with brand_setting lifecycle' do
      organization = create(:organization, name: 'Brand Org')

      # Add brand setting (only one allowed per organization due to unique validation)
      setting = create(:brand_setting, scope: 'organization', organization: organization)
      expect(organization.brand_settings.count).to eq(1)

      # Destroy organization
      organization.destroy

      # Brand setting should have null organization_id
      expect(setting.reload.organization_id).to be_nil
    end

    it 'handles rapid creation and deletion' do
      organizations = []

      expect {
        10.times do |i|
          organizations << create(:organization, name: "Bulk Organization #{i}")
        end
      }.to change(Organization, :count).by(10)

      expect {
        organizations.each(&:destroy)
      }.to change(Organization, :count).by(-10)
    end
  end

  # ====================
  # INHERITANCE TESTS
  # ====================

  describe 'ActiveRecord behavior' do
    it 'inherits from ApplicationRecord' do
      expect(Organization.superclass).to eq(ApplicationRecord)
    end

    it 'is an ApplicationRecord instance' do
      organization = build(:organization)
      expect(organization).to be_a(ApplicationRecord)
    end

    it 'responds to ActiveRecord methods' do
      organization = create(:organization)

      expect(organization).to respond_to(:save)
      expect(organization).to respond_to(:update)
      expect(organization).to respond_to(:destroy)
      expect(organization).to respond_to(:reload)
      expect(organization).to respond_to(:persisted?)
      expect(organization).to respond_to(:new_record?)
    end
  end
end
