# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MicrocreditOption, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid microcredit_option' do
      option = build(:microcredit_option)
      expect(option).to be_valid, "Factory should create a valid microcredit_option"
    end

    it 'creates option with associations' do
      option = create(:microcredit_option)
      expect(option.microcredit).not_to be_nil
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires name' do
      option = build(:microcredit_option, name: nil)
      expect(option).not_to be_valid
      expect(option.errors[:name]).to include("no puede estar en blanco")
    end

    it 'requires microcredit' do
      option = build(:microcredit_option, microcredit: nil)
      expect(option).not_to be_valid
      expect(option.errors[:microcredit]).to include("must exist")
    end

    it 'accepts valid attributes' do
      microcredit = create(:microcredit)
      option = build(:microcredit_option,
        name: "Test Option",
        microcredit: microcredit
      )
      expect(option).to be_valid
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates microcredit_option with valid attributes' do
      expect {
        create(:microcredit_option)
      }.to change(described_class, :count).by(1)
    end

    it 'reads microcredit_option attributes correctly' do
      microcredit = create(:microcredit)
      option = create(:microcredit_option,
        name: "Test Option",
        microcredit: microcredit
      )

      found_option = described_class.find(option.id)
      expect(found_option.name).to eq("Test Option")
      expect(found_option.microcredit_id).to eq(microcredit.id)
    end

    it 'updates microcredit_option attributes' do
      option = create(:microcredit_option, name: "Original Name")

      option.update(name: "Updated Name")

      expect(option.reload.name).to eq("Updated Name")
    end

    it 'deletes microcredit_option' do
      option = create(:microcredit_option)

      expect {
        option.destroy
      }.to change(described_class, :count).by(-1)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to microcredit' do
      option = create(:microcredit_option)
      expect(option).to respond_to(:microcredit)
      expect(option.microcredit).to be_instance_of(Microcredit)
    end

    it 'belongs to parent' do
      parent_option = create(:microcredit_option)
      child_option = create(:microcredit_option, parent: parent_option)

      expect(child_option).to respond_to(:parent)
      expect(child_option.parent).to be_instance_of(described_class)
      expect(child_option.parent).to eq(parent_option)
    end

    it 'has many children' do
      parent = create(:microcredit_option)
      child1 = create(:microcredit_option, parent: parent)
      child2 = create(:microcredit_option, parent: parent)

      expect(parent).to respond_to(:children)
      expect(parent.children.count).to eq(2)
      expect(parent.children).to include(child1)
      expect(parent.children).to include(child2)
    end

    it 'allows root options without parent' do
      root_option = build(:microcredit_option, parent: nil)
      expect(root_option).to be_valid
      expect(root_option.parent).to be_nil
    end

    it 'is associated with microcredit' do
      microcredit = create(:microcredit)
      option = create(:microcredit_option, microcredit: microcredit)

      expect(microcredit.microcredit_options).to include(option)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.root_parents' do
      it 'returns only options without parent' do
        root1 = create(:microcredit_option, parent: nil)
        root2 = create(:microcredit_option, parent: nil)
        child = create(:microcredit_option, parent: root1)

        results = described_class.root_parents

        expect(results).to include(root1)
        expect(results).to include(root2)
        expect(results).not_to include(child)
      end
    end

    describe '.without_children' do
      it 'returns only leaf options' do
        root = create(:microcredit_option)
        child = create(:microcredit_option, parent: root)
        leaf = create(:microcredit_option)

        results = described_class.without_children

        expect(results).to include(child), "Child option should be included (no children)"
        expect(results).to include(leaf), "Leaf option should be included (no children)"
        expect(results).not_to include(root), "Root option should not be included (has children)"
      end
    end
  end

  # ====================
  # HIERARCHICAL TESTS
  # ====================

  describe 'hierarchical structure' do
    it 'creates three-level hierarchy' do
      root = create(:microcredit_option, name: "Root")
      child = create(:microcredit_option, name: "Child", parent: root)
      grandchild = create(:microcredit_option, name: "Grandchild", parent: child)

      expect(root.parent).to be_nil
      expect(child.parent).to eq(root)
      expect(grandchild.parent).to eq(child)

      expect(root.children.count).to eq(1)
      expect(root.children).to include(child)

      expect(child.children.count).to eq(1)
      expect(child.children).to include(grandchild)

      expect(grandchild.children.count).to eq(0)
    end

    it 'handles multiple children per parent' do
      parent = create(:microcredit_option, name: "Parent")
      children = 5.times.map { |i| create(:microcredit_option, name: "Child #{i}", parent: parent) }

      expect(parent.children.count).to eq(5)

      children.each do |child|
        expect(child.parent).to eq(parent)
        expect(parent.children).to include(child)
      end
    end

    it 'allows sibling options with same parent' do
      parent = create(:microcredit_option, name: "Parent")
      sibling1 = create(:microcredit_option, name: "Sibling 1", parent: parent)
      sibling2 = create(:microcredit_option, name: "Sibling 2", parent: parent)

      expect(sibling1.parent).to eq(parent)
      expect(sibling2.parent).to eq(parent)
      expect(parent.children.count).to eq(2)
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    it 'correctly identifies root options' do
      root = create(:microcredit_option, parent: nil)
      child = create(:microcredit_option, parent: root)

      expect(root.parent).to be_nil
      expect(child.parent).not_to be_nil
    end

    it 'correctly identifies leaf options' do
      root = create(:microcredit_option)
      leaf = create(:microcredit_option, parent: root)

      expect(root.children.any?).to be(true), "Root should have children"
      expect(leaf.children.empty?).to be(true), "Leaf should have no children"
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles deletion of parent option' do
      parent = create(:microcredit_option)
      child = create(:microcredit_option, parent: parent)

      parent.destroy

      expect {
        child.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'handles empty name' do
      option = build(:microcredit_option, name: "")
      expect(option).not_to be_valid
    end

    it 'handles very long name' do
      option = build(:microcredit_option, name: "A" * 1000)
      expect(option).to be_valid
    end

    it 'handles special characters in name' do
      option = build(:microcredit_option, name: "Option with émojis 💰 and symbols €$")
      expect(option).to be_valid
    end

    it 'handles same name for different options' do
      microcredit = create(:microcredit)
      option1 = create(:microcredit_option, name: "Duplicate Name", microcredit: microcredit)
      option2 = build(:microcredit_option, name: "Duplicate Name", microcredit: microcredit)

      # No uniqueness constraint, so duplicates are allowed
      expect(option2).to be_valid
    end

    it 'handles intern_code attribute' do
      option = create(:microcredit_option, intern_code: "CODE123")

      expect(option.intern_code).to eq("CODE123")
      expect(option.reload.intern_code).to eq("CODE123")
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'maintains referential integrity across hierarchy' do
      root = create(:microcredit_option, name: "Root")
      child1 = create(:microcredit_option, name: "Child 1", parent: root)
      child2 = create(:microcredit_option, name: "Child 2", parent: root)
      grandchild = create(:microcredit_option, name: "Grandchild", parent: child1)

      # Verify full hierarchy
      expect(root.children.count).to eq(2)
      expect(child1.children.count).to eq(1)
      expect(child2.children.count).to eq(0)
      expect(grandchild.children.count).to eq(0)

      # Verify parent relationships
      expect(root.parent_id).to be_nil
      expect(child1.parent_id).to eq(root.id)
      expect(child2.parent_id).to eq(root.id)
      expect(grandchild.parent_id).to eq(child1.id)
    end

    it 'tracks full lifecycle of hierarchical options' do
      microcredit = create(:microcredit)
      initial_count = described_class.count

      # Create root
      root = create(:microcredit_option, microcredit: microcredit, name: "Root")
      expect(described_class.count).to eq(initial_count + 1)

      # Create children
      child1 = create(:microcredit_option, microcredit: microcredit, parent: root, name: "Child 1")
      child2 = create(:microcredit_option, microcredit: microcredit, parent: root, name: "Child 2")
      expect(described_class.count).to eq(initial_count + 3)

      # Verify scopes
      expect(described_class.root_parents).to include(root)
      expect(described_class.without_children).to include(child1)
      expect(described_class.without_children).to include(child2)
      expect(described_class.without_children).not_to include(root)

      # Delete children
      child1.destroy
      child2.destroy
      expect(described_class.count).to eq(initial_count + 1)

      # Now root should be in without_children
      expect(described_class.without_children.reload).to include(root)

      # Delete root
      root.destroy
      expect(described_class.count).to eq(initial_count)
    end

    it 'handles multiple microcredits with their own option hierarchies' do
      microcredit1 = create(:microcredit, title: "Microcredit 1")
      microcredit2 = create(:microcredit, title: "Microcredit 2")

      # Create hierarchy for microcredit1
      root1 = create(:microcredit_option, microcredit: microcredit1, name: "Root 1")
      child1 = create(:microcredit_option, microcredit: microcredit1, parent: root1, name: "Child 1")

      # Create hierarchy for microcredit2
      root2 = create(:microcredit_option, microcredit: microcredit2, name: "Root 2")
      child2 = create(:microcredit_option, microcredit: microcredit2, parent: root2, name: "Child 2")

      # Verify separate hierarchies
      expect(microcredit1.microcredit_options.count).to eq(2)
      expect(microcredit2.microcredit_options.count).to eq(2)

      expect(microcredit1.microcredit_options).to include(root1)
      expect(microcredit1.microcredit_options).to include(child1)
      expect(microcredit1.microcredit_options).not_to include(root2)
      expect(microcredit1.microcredit_options).not_to include(child2)

      expect(microcredit2.microcredit_options).to include(root2)
      expect(microcredit2.microcredit_options).to include(child2)
      expect(microcredit2.microcredit_options).not_to include(root1)
      expect(microcredit2.microcredit_options).not_to include(child1)
    end
  end
end
