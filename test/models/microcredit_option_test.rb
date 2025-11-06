require 'test_helper'

class MicrocreditOptionTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid microcredit_option" do
    option = build(:microcredit_option)
    assert option.valid?, "Factory should create a valid microcredit_option"
  end

  test "factory creates option with associations" do
    option = create(:microcredit_option)
    assert_not_nil option.microcredit
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require name" do
    option = build(:microcredit_option, name: nil)
    assert_not option.valid?
    assert_includes option.errors[:name], "can't be blank"
  end

  test "should require microcredit" do
    option = build(:microcredit_option, microcredit: nil)
    assert_not option.valid?
    assert_includes option.errors[:microcredit], "must exist"
  end

  test "should accept valid attributes" do
    microcredit = create(:microcredit)
    option = build(:microcredit_option,
      name: "Test Option",
      microcredit: microcredit
    )
    assert option.valid?
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create microcredit_option with valid attributes" do
    assert_difference('MicrocreditOption.count', 1) do
      create(:microcredit_option)
    end
  end

  test "should read microcredit_option attributes correctly" do
    microcredit = create(:microcredit)
    option = create(:microcredit_option,
      name: "Test Option",
      microcredit: microcredit
    )

    found_option = MicrocreditOption.find(option.id)
    assert_equal "Test Option", found_option.name
    assert_equal microcredit.id, found_option.microcredit_id
  end

  test "should update microcredit_option attributes" do
    option = create(:microcredit_option, name: "Original Name")

    option.update(name: "Updated Name")

    assert_equal "Updated Name", option.reload.name
  end

  test "should delete microcredit_option" do
    option = create(:microcredit_option)

    assert_difference('MicrocreditOption.count', -1) do
      option.destroy
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to microcredit" do
    option = create(:microcredit_option)
    assert_respond_to option, :microcredit
    assert_instance_of Microcredit, option.microcredit
  end

  test "should belong to parent" do
    parent_option = create(:microcredit_option)
    child_option = create(:microcredit_option, parent: parent_option)

    assert_respond_to child_option, :parent
    assert_instance_of MicrocreditOption, child_option.parent
    assert_equal parent_option, child_option.parent
  end

  test "should have many children" do
    parent = create(:microcredit_option)
    child1 = create(:microcredit_option, parent: parent)
    child2 = create(:microcredit_option, parent: parent)

    assert_respond_to parent, :children
    assert_equal 2, parent.children.count
    assert_includes parent.children, child1
    assert_includes parent.children, child2
  end

  test "should allow root options without parent" do
    root_option = build(:microcredit_option, parent: nil)
    assert root_option.valid?
    assert_nil root_option.parent
  end

  test "should be associated with microcredit" do
    microcredit = create(:microcredit)
    option = create(:microcredit_option, microcredit: microcredit)

    assert_includes microcredit.microcredit_options, option
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "root_parents scope should return only options without parent" do
    root1 = create(:microcredit_option, parent: nil)
    root2 = create(:microcredit_option, parent: nil)
    child = create(:microcredit_option, parent: root1)

    results = MicrocreditOption.root_parents

    assert_includes results, root1
    assert_includes results, root2
    assert_not_includes results, child
  end

  test "without_children scope should return only leaf options" do
    root = create(:microcredit_option)
    child = create(:microcredit_option, parent: root)
    leaf = create(:microcredit_option)

    results = MicrocreditOption.without_children

    assert_includes results, child, "Child option should be included (no children)"
    assert_includes results, leaf, "Leaf option should be included (no children)"
    assert_not_includes results, root, "Root option should not be included (has children)"
  end

  # ====================
  # HIERARCHICAL TESTS
  # ====================

  test "should create three-level hierarchy" do
    root = create(:microcredit_option, name: "Root")
    child = create(:microcredit_option, name: "Child", parent: root)
    grandchild = create(:microcredit_option, name: "Grandchild", parent: child)

    assert_nil root.parent
    assert_equal root, child.parent
    assert_equal child, grandchild.parent

    assert_equal 1, root.children.count
    assert_includes root.children, child

    assert_equal 1, child.children.count
    assert_includes child.children, grandchild

    assert_equal 0, grandchild.children.count
  end

  test "should handle multiple children per parent" do
    parent = create(:microcredit_option, name: "Parent")
    children = 5.times.map { |i| create(:microcredit_option, name: "Child #{i}", parent: parent) }

    assert_equal 5, parent.children.count

    children.each do |child|
      assert_equal parent, child.parent
      assert_includes parent.children, child
    end
  end

  test "should allow sibling options with same parent" do
    parent = create(:microcredit_option, name: "Parent")
    sibling1 = create(:microcredit_option, name: "Sibling 1", parent: parent)
    sibling2 = create(:microcredit_option, name: "Sibling 2", parent: parent)

    assert_equal parent, sibling1.parent
    assert_equal parent, sibling2.parent
    assert_equal 2, parent.children.count
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "should correctly identify root options" do
    root = create(:microcredit_option, parent: nil)
    child = create(:microcredit_option, parent: root)

    assert_nil root.parent
    assert_not_nil child.parent
  end

  test "should correctly identify leaf options" do
    root = create(:microcredit_option)
    leaf = create(:microcredit_option, parent: root)

    assert root.children.any?, "Root should have children"
    assert leaf.children.empty?, "Leaf should have no children"
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle deletion of parent option" do
    parent = create(:microcredit_option)
    child = create(:microcredit_option, parent: parent)

    parent.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      child.reload
    end
  end

  test "should handle empty name" do
    option = build(:microcredit_option, name: "")
    assert_not option.valid?
  end

  test "should handle very long name" do
    option = build(:microcredit_option, name: "A" * 1000)
    assert option.valid?
  end

  test "should handle special characters in name" do
    option = build(:microcredit_option, name: "Option with émojis 💰 and symbols €$")
    assert option.valid?
  end

  test "should handle same name for different options" do
    microcredit = create(:microcredit)
    option1 = create(:microcredit_option, name: "Duplicate Name", microcredit: microcredit)
    option2 = build(:microcredit_option, name: "Duplicate Name", microcredit: microcredit)

    # No uniqueness constraint, so duplicates are allowed
    assert option2.valid?
  end

  test "should handle intern_code attribute" do
    option = create(:microcredit_option, intern_code: "CODE123")

    assert_equal "CODE123", option.intern_code
    assert_equal "CODE123", option.reload.intern_code
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should maintain referential integrity across hierarchy" do
    root = create(:microcredit_option, name: "Root")
    child1 = create(:microcredit_option, name: "Child 1", parent: root)
    child2 = create(:microcredit_option, name: "Child 2", parent: root)
    grandchild = create(:microcredit_option, name: "Grandchild", parent: child1)

    # Verify full hierarchy
    assert_equal 2, root.children.count
    assert_equal 1, child1.children.count
    assert_equal 0, child2.children.count
    assert_equal 0, grandchild.children.count

    # Verify parent relationships
    assert_nil root.parent_id
    assert_equal root.id, child1.parent_id
    assert_equal root.id, child2.parent_id
    assert_equal child1.id, grandchild.parent_id
  end

  test "should track full lifecycle of hierarchical options" do
    microcredit = create(:microcredit)
    initial_count = MicrocreditOption.count

    # Create root
    root = create(:microcredit_option, microcredit: microcredit, name: "Root")
    assert_equal initial_count + 1, MicrocreditOption.count

    # Create children
    child1 = create(:microcredit_option, microcredit: microcredit, parent: root, name: "Child 1")
    child2 = create(:microcredit_option, microcredit: microcredit, parent: root, name: "Child 2")
    assert_equal initial_count + 3, MicrocreditOption.count

    # Verify scopes
    assert_includes MicrocreditOption.root_parents, root
    assert_includes MicrocreditOption.without_children, child1
    assert_includes MicrocreditOption.without_children, child2
    assert_not_includes MicrocreditOption.without_children, root

    # Delete children
    child1.destroy
    child2.destroy
    assert_equal initial_count + 1, MicrocreditOption.count

    # Now root should be in without_children
    assert_includes MicrocreditOption.without_children.reload, root

    # Delete root
    root.destroy
    assert_equal initial_count, MicrocreditOption.count
  end

  test "should handle multiple microcredits with their own option hierarchies" do
    microcredit1 = create(:microcredit, title: "Microcredit 1")
    microcredit2 = create(:microcredit, title: "Microcredit 2")

    # Create hierarchy for microcredit1
    root1 = create(:microcredit_option, microcredit: microcredit1, name: "Root 1")
    child1 = create(:microcredit_option, microcredit: microcredit1, parent: root1, name: "Child 1")

    # Create hierarchy for microcredit2
    root2 = create(:microcredit_option, microcredit: microcredit2, name: "Root 2")
    child2 = create(:microcredit_option, microcredit: microcredit2, parent: root2, name: "Child 2")

    # Verify separate hierarchies
    assert_equal 2, microcredit1.microcredit_options.count
    assert_equal 2, microcredit2.microcredit_options.count

    assert_includes microcredit1.microcredit_options, root1
    assert_includes microcredit1.microcredit_options, child1
    assert_not_includes microcredit1.microcredit_options, root2
    assert_not_includes microcredit1.microcredit_options, child2

    assert_includes microcredit2.microcredit_options, root2
    assert_includes microcredit2.microcredit_options, child2
    assert_not_includes microcredit2.microcredit_options, root1
    assert_not_includes microcredit2.microcredit_options, child1
  end
end
