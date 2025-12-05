# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::ImpulsaAuthor, type: :model do
  let(:user) { create(:user) }

  describe 'included module' do
    it 'extends ActiveSupport::Concern' do
      expect(EngineUser::ImpulsaAuthor).to be_a(ActiveSupport::Concern)
    end

    it 'is included in User model' do
      expect(user.class.ancestors).to include(EngineUser::ImpulsaAuthor)
    end
  end

  describe '#impulsa_author?' do
    context 'when user has impulsa_author flag set to true' do
      before do
        user.update_column(:flags, user.flags | 16) # impulsa_author flag (bit 5)
      end

      it 'returns true' do
        expect(user.impulsa_author?).to be true
      end

      it 'matches impulsa_author flag value' do
        expect(user.impulsa_author?).to eq(user.impulsa_author)
      end

      it 'delegates to impulsa_author attribute' do
        # Explicitly test that the method returns the attribute value
        attribute_value = user.impulsa_author
        method_value = user.impulsa_author?
        expect(method_value).to eq(attribute_value)
      end
    end

    context 'when user has impulsa_author flag set to false' do
      before do
        user.update_column(:flags, user.flags & ~16) # Clear impulsa_author flag
      end

      it 'returns false' do
        expect(user.impulsa_author?).to be false
      end

      it 'matches impulsa_author flag value' do
        expect(user.impulsa_author?).to eq(user.impulsa_author)
      end
    end

    context 'when user is newly created' do
      let(:new_user) { build(:user) }

      it 'returns false by default' do
        expect(new_user.impulsa_author?).to be false
      end
    end

    context 'when checking multiple users' do
      let(:author_user) { create(:user) }
      let(:regular_user) { create(:user) }

      before do
        author_user.update_column(:flags, author_user.flags | 16)
        regular_user.update_column(:flags, regular_user.flags & ~16)
      end

      it 'correctly identifies author users' do
        expect(author_user.impulsa_author?).to be true
        expect(regular_user.impulsa_author?).to be false
      end
    end
  end

  describe 'flag consistency' do
    it 'impulsa_author? method uses impulsa_author flag' do
      user.update_column(:flags, user.flags | 16)
      expect(user.impulsa_author).to be true
      expect(user.impulsa_author?).to eq(user.impulsa_author)

      user.update_column(:flags, user.flags & ~16)
      user.reload
      expect(user.impulsa_author).to be false
      expect(user.impulsa_author?).to eq(user.impulsa_author)
    end
  end

  describe 'method behavior' do
    it 'returns a boolean value' do
      result = user.impulsa_author?
      expect([true, false]).to include(result)
    end

    it 'does not raise errors when called multiple times' do
      expect { 3.times { user.impulsa_author? } }.not_to raise_error
    end

    it 'reflects flag changes immediately after reload' do
      expect(user.impulsa_author?).to be false

      user.update_column(:flags, user.flags | 16)
      user.reload

      expect(user.impulsa_author?).to be true
    end

    it 'can be called on unsaved user' do
      new_user = build(:user)
      expect { new_user.impulsa_author? }.not_to raise_error
      expect(new_user.impulsa_author?).to be false
    end

    it 'persists correctly after save' do
      new_user = build(:user)
      new_user.update_column(:flags, 16) if new_user.persisted?
      new_user.save! unless new_user.persisted?
      new_user.update_column(:flags, new_user.flags | 16)
      new_user.reload
      expect(new_user.impulsa_author?).to be true
    end
  end

  describe 'integration with User model' do
    it 'method is defined on User instances' do
      expect(user).to respond_to(:impulsa_author?)
    end

    it 'method returns same value as impulsa_author attribute' do
      user.update_column(:flags, user.flags | 16)
      expect(user.impulsa_author?).to eq(user.impulsa_author)
    end

    it 'works correctly with user queries' do
      author1 = create(:user)
      author2 = create(:user)
      regular = create(:user)

      author1.update_column(:flags, author1.flags | 16)
      author2.update_column(:flags, author2.flags | 16)

      expect(author1.impulsa_author?).to be true
      expect(author2.impulsa_author?).to be true
      expect(regular.impulsa_author?).to be false
    end
  end

  describe 'concern structure' do
    it 'does not define has_many associations' do
      expect(user.class.reflect_on_all_associations(:has_many).map(&:name)).not_to include(:impulsa_projects)
    end

    it 'concern is properly namespaced' do
      expect(EngineUser::ImpulsaAuthor.name).to eq('EngineUser::ImpulsaAuthor')
    end

    it 'module extends ActiveSupport::Concern' do
      expect(EngineUser::ImpulsaAuthor.ancestors).to include(ActiveSupport::Concern)
    end
  end

  describe 'attribute delegation' do
    it 'impulsa_author? directly returns impulsa_author attribute value' do
      user.update_column(:flags, user.flags | 16)
      attribute_value = user.impulsa_author
      method_value = user.impulsa_author?
      expect(method_value).to eq(attribute_value)
      expect(method_value).to be true
    end

    it 'method does not perform complex logic' do
      user.update_column(:flags, user.flags | 16)
      expect(user.impulsa_author?).to eq(user.impulsa_author)
    end
  end
end
