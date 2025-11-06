require 'test_helper'

class ImpulsaEditionCategoryTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid impulsa_edition_category" do
    category = build(:impulsa_edition_category)
    assert category.valid?, "Factory should create a valid impulsa_edition_category"
  end

  test "factory creates category with associations" do
    category = create(:impulsa_edition_category)
    assert_not_nil category.impulsa_edition
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require name" do
    category = build(:impulsa_edition_category, name: nil)
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "should require category_type" do
    category = build(:impulsa_edition_category, category_type: nil)
    assert_not category.valid?
    assert_includes category.errors[:category_type], "can't be blank"
  end

  test "should require winners" do
    category = build(:impulsa_edition_category, winners: nil)
    assert_not category.valid?
    assert_includes category.errors[:winners], "can't be blank"
  end

  test "should require prize" do
    category = build(:impulsa_edition_category, prize: nil)
    assert_not category.valid?
    assert_includes category.errors[:prize], "can't be blank"
  end

  test "should accept valid attributes" do
    category = build(:impulsa_edition_category,
      name: "Valid Category",
      category_type: 1,
      winners: 5,
      prize: 10000
    )
    assert category.valid?
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "non_authors scope should exclude only_authors categories" do
    normal = create(:impulsa_edition_category, only_authors: false)
    authors_only = create(:impulsa_edition_category, only_authors: true)

    results = ImpulsaEditionCategory.non_authors

    assert_includes results, normal
    assert_not_includes results, authors_only
  end

  test "state scope should return only state categories" do
    state = create(:impulsa_edition_category, :state)
    internal = create(:impulsa_edition_category, :internal)
    territorial = create(:impulsa_edition_category, :territorial)

    results = ImpulsaEditionCategory.state

    assert_includes results, state
    assert_not_includes results, internal
    assert_not_includes results, territorial
  end

  test "territorial scope should return only territorial categories" do
    territorial = create(:impulsa_edition_category, :territorial)
    state = create(:impulsa_edition_category, :state)

    results = ImpulsaEditionCategory.territorial

    assert_includes results, territorial
    assert_not_includes results, state
  end

  test "internal scope should return only internal categories" do
    internal = create(:impulsa_edition_category, :internal)
    state = create(:impulsa_edition_category, :state)

    results = ImpulsaEditionCategory.internal

    assert_includes results, internal
    assert_not_includes results, state
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "category_type_name should return correct name for internal" do
    category = create(:impulsa_edition_category, :internal)
    assert_equal :internal, category.category_type_name
  end

  test "category_type_name should return correct name for state" do
    category = create(:impulsa_edition_category, :state)
    assert_equal :state, category.category_type_name
  end

  test "category_type_name should return correct name for territorial" do
    category = create(:impulsa_edition_category, :territorial)
    assert_equal :territorial, category.category_type_name
  end

  test "has_territory? should return true for territorial categories" do
    category = create(:impulsa_edition_category, :territorial)
    assert category.has_territory?
  end

  test "has_territory? should return false for non-territorial categories" do
    state = create(:impulsa_edition_category, :state)
    internal = create(:impulsa_edition_category, :internal)

    assert_not state.has_territory?
    assert_not internal.has_territory?
  end

  test "translatable? should return true when coofficial_language is present" do
    category = create(:impulsa_edition_category, :with_coofficial_language)
    assert category.translatable?
  end

  test "translatable? should return false when coofficial_language is blank" do
    category = create(:impulsa_edition_category, coofficial_language: nil)
    assert_not category.translatable?
  end

  test "coofficial_language_name should return language name when present" do
    category = create(:impulsa_edition_category, :with_coofficial_language)
    # Should return the locale name for :ca (Catalan)
    assert_not_nil category.coofficial_language_name
  end

  test "coofficial_language_name should return nil when not present" do
    category = create(:impulsa_edition_category, coofficial_language: nil)
    assert_nil category.coofficial_language_name
  end

  test "territories should parse pipe-separated values" do
    category = create(:impulsa_edition_category)
    # Set the internal field directly to avoid calling the setter which expects an array
    category.update_column(:territories, "a_01|a_02|a_03")

    assert_equal ["a_01", "a_02", "a_03"], category.territories
  end

  test "territories should return empty array when nil" do
    category = create(:impulsa_edition_category)
    category.update_column(:territories, nil)

    assert_equal [], category.territories
  end

  test "territories= should join array with pipes" do
    category = create(:impulsa_edition_category)
    category.territories = ["a_01", "a_02", "a_03"]

    assert_equal "a_01|a_02|a_03", category[:territories]
  end

  test "territories= should filter out blank values" do
    category = create(:impulsa_edition_category)
    category.territories = ["a_01", "", "a_02", nil, "a_03"]

    assert_equal "a_01|a_02|a_03", category[:territories]
  end

  test "prewinners should return double the winners" do
    category = create(:impulsa_edition_category, winners: 5)
    assert_equal 10, category.prewinners
  end

  test "wizard_raw should return YAML string without ActiveSupport hash prefix" do
    category = create(:impulsa_edition_category)
    category.wizard = { step1: "value1", step2: "value2" }

    result = category.wizard_raw
    assert_instance_of String, result
    assert_not_includes result, "!ruby/hash:ActiveSupport::HashWithIndifferentAccess"
  end

  test "wizard_raw= should parse YAML and set wizard" do
    category = create(:impulsa_edition_category)
    yaml_string = "---\nstep1: value1\nstep2: value2\n"

    category.wizard_raw = yaml_string

    assert_equal "value1", category.wizard["step1"]
    assert_equal "value2", category.wizard["step2"]
  end

  test "evaluation_raw should return YAML string without ActiveSupport hash prefix" do
    category = create(:impulsa_edition_category)
    category.evaluation = { criteria1: "value1", criteria2: "value2" }

    result = category.evaluation_raw
    assert_instance_of String, result
    assert_not_includes result, "!ruby/hash:ActiveSupport::HashWithIndifferentAccess"
  end

  test "evaluation_raw= should parse YAML and set evaluation" do
    category = create(:impulsa_edition_category)
    yaml_string = "---\ncriteria1: value1\ncriteria2: value2\n"

    category.evaluation_raw = yaml_string

    assert_equal "value1", category.evaluation["criteria1"]
    assert_equal "value2", category.evaluation["criteria2"]
  end

  # ====================
  # FLAG TESTS
  # ====================

  test "has_votings flag should default to false" do
    category = create(:impulsa_edition_category)
    assert_not category.has_votings?
  end

  test "has_votings flag should be settable to true" do
    category = create(:impulsa_edition_category, :with_votings)
    assert category.has_votings?
  end

  test "has_votings flag should be toggleable" do
    category = create(:impulsa_edition_category)

    category.has_votings = true
    category.save
    assert category.reload.has_votings?

    category.has_votings = false
    category.save
    assert_not category.reload.has_votings?
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to impulsa_edition" do
    category = create(:impulsa_edition_category)
    assert_respond_to category, :impulsa_edition
    assert_instance_of ImpulsaEdition, category.impulsa_edition
  end

  test "should have many impulsa_projects" do
    category = create(:impulsa_edition_category)
    assert_respond_to category, :impulsa_projects
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle zero winners" do
    category = build(:impulsa_edition_category, winners: 0)
    assert category.valid?
    assert_equal 0, category.prewinners
  end

  test "should handle zero prize" do
    category = build(:impulsa_edition_category, prize: 0)
    assert category.valid?
  end

  test "should handle very long name" do
    category = build(:impulsa_edition_category, name: "A" * 1000)
    assert category.valid?
  end

  test "should handle special characters in name" do
    category = build(:impulsa_edition_category, name: "Category with émojis 🎉 and symbols")
    assert category.valid?
  end

  test "should handle empty wizard store" do
    category = create(:impulsa_edition_category)
    assert_not_nil category.wizard
  end

  test "should handle empty evaluation store" do
    category = create(:impulsa_edition_category)
    assert_not_nil category.evaluation
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should create multiple categories for same edition" do
    edition = create(:impulsa_edition)

    cat1 = create(:impulsa_edition_category, :internal, impulsa_edition: edition)
    cat2 = create(:impulsa_edition_category, :state, impulsa_edition: edition)
    cat3 = create(:impulsa_edition_category, :territorial, impulsa_edition: edition)

    assert_equal 3, edition.impulsa_edition_categories.count
  end

  test "should handle all category types correctly" do
    internal = create(:impulsa_edition_category, :internal)
    state = create(:impulsa_edition_category, :state)
    territorial = create(:impulsa_edition_category, :territorial)

    assert_equal 0, internal.category_type
    assert_equal 1, state.category_type
    assert_equal 2, territorial.category_type

    assert_equal :internal, internal.category_type_name
    assert_equal :state, state.category_type_name
    assert_equal :territorial, territorial.category_type_name
  end

  test "should maintain territorial data correctly" do
    category = create(:impulsa_edition_category, :territorial)
    category.territories = ["a_13", "a_09", "a_01"]
    category.save

    assert category.has_territory?
    assert_equal 3, category.territories.count
    assert_includes category.territories, "a_13"
  end
end
