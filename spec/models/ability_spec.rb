# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }

  describe 'Guest user (not logged in)' do
    let(:user) { nil }

    it 'can show notices' do
      expect(ability).to be_able_to(:show, Notice)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User)
    end

    it 'cannot manage elections' do
      expect(ability).not_to be_able_to(:manage, Election)
    end
  end

  describe 'Regular authenticated user' do
    let(:user) { create(:user, :with_dni) }
    let(:other_user) { create(:user, :with_dni) }

    it 'can view their own profile' do
      expect(ability).to be_able_to(:show, user)
      expect(ability).to be_able_to(:read, user)
    end

    it 'can update their own profile' do
      expect(ability).to be_able_to(:update, user)
    end

    it 'cannot view other users profiles' do
      expect(ability).not_to be_able_to(:show, other_user)
    end

    it 'cannot update other users' do
      expect(ability).not_to be_able_to(:update, other_user)
    end

    it 'cannot manage elections' do
      expect(ability).not_to be_able_to(:manage, Election)
    end

    it 'can show notices' do
      expect(ability).to be_able_to(:show, Notice)
    end
  end

  describe 'Superadmin user' do
    let(:user) { create(:user, :with_dni, :admin, superadmin: true) }

    it 'can manage all resources' do
      expect(ability).to be_able_to(:manage, :all)
    end

    it 'can manage users' do
      expect(ability).to be_able_to(:manage, User)
    end

    it 'can manage elections' do
      expect(ability).to be_able_to(:manage, Election)
    end

    it 'can manage reports' do
      expect(ability).to be_able_to(:manage, Report)
    end

    it 'can manage notices' do
      expect(ability).to be_able_to(:manage, Notice)
    end

    it 'can destroy users' do
      expect(ability).to be_able_to(:destroy, User)
    end
  end

  describe 'Regular admin user (non-superadmin)' do
    let(:user) { create(:user, :with_dni, :admin, superadmin: false) }

    it 'can manage notices' do
      expect(ability).to be_able_to(:manage, Notice)
    end

    it 'can manage reports' do
      expect(ability).to be_able_to(:manage, Report)
    end

    it 'can read users' do
      expect(ability).to be_able_to(:read, User)
    end

    it 'can create users' do
      expect(ability).to be_able_to(:create, User)
    end

    it 'can update users' do
      expect(ability).to be_able_to(:update, User)
    end

    it 'cannot destroy users' do
      expect(ability).not_to be_able_to(:destroy, User)
    end

    it 'cannot manage elections' do
      expect(ability).not_to be_able_to(:manage, Election)
    end

    it 'can read elections' do
      expect(ability).to be_able_to(:read, Election)
    end

    it 'cannot manage report groups' do
      expect(ability).not_to be_able_to(:manage, ReportGroup)
    end

    it 'can manage brand settings' do
      expect(ability).to be_able_to(:manage, BrandSetting)
    end

    it 'can manage brand images' do
      expect(ability).to be_able_to(:manage, BrandImage)
    end
  end

  describe 'Finances admin user' do
    let(:user) { create(:user, :with_dni, finances_admin: true) }

    it 'can manage collaborations' do
      expect(ability).to be_able_to(:manage, Collaboration)
    end if defined?(Collaboration)

    it 'can manage orders' do
      expect(ability).to be_able_to(:manage, Order)
    end if defined?(Order)

    it 'cannot destroy orders' do
      expect(ability).not_to be_able_to(:destroy, Order)
    end if defined?(Order)

    it 'cannot destroy collaborations' do
      expect(ability).not_to be_able_to(:destroy, Collaboration)
    end if defined?(Collaboration)

    it 'can read users' do
      expect(ability).to be_able_to(:read, User)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User)
    end
  end

  describe 'Impulsa admin user' do
    let(:user) { create(:user, :with_dni, impulsa_admin: true) }

    it 'can read users' do
      expect(ability).to be_able_to(:read, User)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User)
    end
  end

  describe 'Verifier user' do
    let(:user) { create(:user, :with_dni, verifier: true) }

    it 'can read users' do
      expect(ability).to be_able_to(:read, User)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User)
    end

    it 'cannot manage elections' do
      expect(ability).not_to be_able_to(:manage, Election)
    end
  end

  describe 'Paper authority user' do
    let(:user) { create(:user, :with_dni, paper_authority: true) }

    it 'can read users' do
      expect(ability).to be_able_to(:read, User)
    end

    it 'cannot manage users' do
      expect(ability).not_to be_able_to(:manage, User)
    end
  end

  describe 'Security restrictions' do
    describe 'for regular admin' do
      let(:user) { create(:user, :with_dni, :admin, superadmin: false) }

      it 'cannot destroy users even with admin role' do
        expect(ability).not_to be_able_to(:destroy, User)
      end

      it 'cannot manage elections even with admin role' do
        expect(ability).not_to be_able_to(:manage, Election)
      end

      it 'can still read elections' do
        expect(ability).to be_able_to(:read, Election)
      end

      it 'cannot manage report groups' do
        expect(ability).not_to be_able_to(:manage, ReportGroup)
      end

      it 'cannot manage spam filters' do
        expect(ability).not_to be_able_to(:manage, SpamFilter)
      end
    end

    describe 'for finances admin' do
      let(:user) { create(:user, :with_dni, finances_admin: true) }

      it 'cannot destroy orders (financial records must be preserved)' do
        expect(ability).not_to be_able_to(:destroy, Order)
      end if defined?(Order)

      it 'cannot destroy collaborations (financial records must be preserved)' do
        expect(ability).not_to be_able_to(:destroy, Collaboration)
      end if defined?(Collaboration)
    end
  end

  describe 'Edge cases' do
    describe 'user with multiple roles' do
      let(:user) { create(:user, :with_dni, :admin, finances_admin: true, impulsa_admin: true, superadmin: false) }

      it 'has admin permissions' do
        expect(ability).to be_able_to(:manage, Notice)
      end

      it 'still cannot destroy users (security restriction)' do
        expect(ability).not_to be_able_to(:destroy, User)
      end
    end

    describe 'user with no special roles' do
      let(:user) { create(:user, :with_dni) }

      it 'has only basic user abilities' do
        expect(ability).to be_able_to(:show, user)
        expect(ability).not_to be_able_to(:manage, Notice)
        expect(ability).not_to be_able_to(:manage, User)
      end
    end
  end
end
