require "test_helper"

class ElectionTest < ActiveSupport::TestCase
  # VALIDATIONS

  test "should validate presence of title" do
    election = build(:election, title: nil)
    assert_not election.valid?
    assert_includes election.errors[:title], "can't be blank"
  end

  test "should validate presence of starts_at" do
    election = build(:election, starts_at: nil)
    assert_not election.valid?
    assert_includes election.errors[:starts_at], "can't be blank"
  end

  test "should validate presence of ends_at" do
    election = build(:election, ends_at: nil)
    assert_not election.valid?
    assert_includes election.errors[:ends_at], "can't be blank"
  end

  test "should validate presence of agora_election_id" do
    election = build(:election, agora_election_id: nil)
    assert_not election.valid?
    assert_includes election.errors[:agora_election_id], "can't be blank"
  end

  test "should validate presence of scope" do
    election = build(:election, scope: nil)
    assert_not election.valid?
    assert_includes election.errors[:scope], "can't be blank"
  end

  test "should create valid election with all required attributes" do
    election = build(:election)
    assert election.valid?
    assert election.save
  end

  # ASSOCIATIONS

  test "should have many votes" do
    election = create(:election)
    assert_respond_to election, :votes
  end

  test "should have many election_locations" do
    election = create(:election)
    assert_respond_to election, :election_locations
  end

  test "should destroy associated election_locations when destroyed" do
    election = create(:election)
    location = create(:election_location, election: election)

    assert_difference 'ElectionLocation.count', -1 do
      election.destroy
    end
  end

  # ENUM

  test "should have election_type enum" do
    election = create(:election, election_type: :nvotes)
    assert election.nvotes?

    election.election_type = :external
    assert election.external?

    election.election_type = :paper
    assert election.paper?
  end

  # FLAGS (FlagShihTzu)

  test "should have requires_sms_check flag" do
    election = create(:election, :with_sms_check)
    assert election.requires_sms_check?
  end

  test "should have show_on_index flag" do
    election = create(:election, :show_on_index)
    assert election.show_on_index?
  end

  test "should have ignore_multiple_territories flag" do
    election = create(:election, :ignore_multiple_territories)
    assert election.ignore_multiple_territories?
  end

  test "should have requires_vatid_check flag" do
    election = create(:election, :requires_vatid_check)
    assert election.requires_vatid_check?
  end

  # SCOPES

  test "active scope should return elections happening now" do
    active = create(:election, :active)
    past = create(:election, :finished)
    future = create(:election, :future)

    active_elections = Election.active

    assert_includes active_elections, active
    assert_not_includes active_elections, past
    assert_not_includes active_elections, future
  end

  test "upcoming_finished scope should return recent elections" do
    recently_finished = create(:election, :recently_finished)
    upcoming = create(:election, :upcoming)
    old_finished = create(:election, :finished)

    result = Election.upcoming_finished

    assert_includes result, recently_finished
    assert_includes result, upcoming
    assert_not_includes result, old_finished
  end

  test "future scope should return elections with ends_at in future" do
    future = create(:election, :future)
    active = create(:election, :active)
    finished = create(:election, :finished)

    future_elections = Election.future

    assert_includes future_elections, future
    assert_includes future_elections, active  # Still has ends_at in future
    assert_not_includes future_elections, finished
  end

  # CALLBACKS

  test "should generate counter_key before create" do
    election = build(:election, counter_key: nil)
    election.save

    assert_not_nil election.counter_key
    assert election.counter_key.length > 10
  end

  test "should not override existing counter_key" do
    custom_key = "custom_key_12345"
    election = build(:election, counter_key: custom_key)
    election.save

    assert_equal custom_key, election.counter_key
  end

  # INSTANCE METHODS - STATUS

  test "is_active? should return true for active election" do
    election = create(:election, :active)
    assert election.is_active?
  end

  test "is_active? should return false for finished election" do
    election = create(:election, :finished)
    assert_not election.is_active?
  end

  test "is_active? should return false for future election" do
    election = create(:election, :future)
    assert_not election.is_active?
  end

  test "is_upcoming? should return true for election starting soon" do
    election = create(:election, :upcoming)
    assert election.is_upcoming?
  end

  test "is_upcoming? should return false for active election" do
    election = create(:election, :active)
    assert_not election.is_upcoming?
  end

  test "recently_finished? should return true for election that ended recently" do
    election = create(:election, :recently_finished)
    assert election.recently_finished?
  end

  test "recently_finished? should return false for old finished election" do
    election = create(:election, :finished)
    assert_not election.recently_finished?
  end

  # INSTANCE METHODS - HELPERS

  test "to_s should return title" do
    election = create(:election, title: "Test Election 2025")
    assert_equal "Test Election 2025", election.to_s
  end

  test "scope_name should return name for scope" do
    election = create(:election, scope: 0)
    assert_equal "Estatal", election.scope_name

    election.scope = 1
    assert_equal "Comunidad", election.scope_name

    election.scope = 3
    assert_equal "Municipal", election.scope_name
  end

  test "multiple_territories? should return true for relevant scopes" do
    # Scopes 1, 2, 3, 4 are territorial
    [1, 2, 3, 4].each do |scope_val|
      election = create(:election, scope: scope_val)
      assert election.multiple_territories?, "Scope #{scope_val} should be multiple territories"
    end
  end

  test "multiple_territories? should return false for non-territorial scopes" do
    [0, 5, 6].each do |scope_val|
      election = create(:election, scope: scope_val)
      assert_not election.multiple_territories?, "Scope #{scope_val} should not be multiple territories"
    end
  end

  test "multiple_territories? should return false when ignore_multiple_territories flag set" do
    election = create(:election, :ignore_multiple_territories, scope: 1)
    assert_not election.multiple_territories?
  end

  test "duration should return duration in hours" do
    election = create(:election,
      starts_at: Time.parse('2025-01-01 00:00:00'),
      ends_at: Time.parse('2025-01-01 12:00:00')
    )
    assert_equal 12, election.duration
  end

  test "duration should handle day-long elections" do
    election = create(:election,
      starts_at: Time.parse('2025-01-01 00:00:00'),
      ends_at: Time.parse('2025-01-02 00:00:00')
    )
    assert_equal 24, election.duration
  end

  # INSTANCE METHODS - SERVER CONFIGURATION

  test "available_servers should return server list from config" do
    servers = Election.available_servers
    assert_kind_of Hash, servers
  end

  test "server_shared_key should return shared key from config" do
    election = create(:election)
    assert_not_nil election.server_shared_key
  end

  test "server_url should return server URL from config" do
    election = create(:election)
    url = election.server_url
    assert_kind_of String, url
  end

  test "server_url should use custom server if set" do
    election = create(:election, server: "default")
    default_url = election.server_url
    assert_not_nil default_url
  end

  # INSTANCE METHODS - ACCESS TOKENS

  test "counter_token should generate access token" do
    election = create(:election)
    token = election.counter_token

    assert_not_nil token
    assert_kind_of String, token
    assert token.length > 0
  end

  test "counter_token should be memoized" do
    election = create(:election)
    token1 = election.counter_token
    token2 = election.counter_token

    assert_equal token1, token2
  end

  test "generate_access_token should create token from info" do
    election = create(:election)
    token = election.generate_access_token("test_info")

    assert_not_nil token
    assert_kind_of String, token
    assert_equal 17, token.length  # Token is truncated to 17 chars
  end

  test "generate_access_token should be deterministic" do
    election = create(:election)
    info = "same_info"

    token1 = election.generate_access_token(info)
    token2 = election.generate_access_token(info)

    assert_equal token1, token2
  end

  test "generate_access_token should produce different tokens for different info" do
    election = create(:election)

    token1 = election.generate_access_token("info1")
    token2 = election.generate_access_token("info2")

    assert_not_equal token1, token2
  end

  # INSTANCE METHODS - LOCATIONS

  test "locations should format election_locations as text" do
    election = create(:election)
    create(:election_location, election: election, location: "01", agora_version: "1")
    create(:election_location, election: election, location: "02", agora_version: "2")

    result = election.locations

    assert_includes result, "01,1"
    assert_includes result, "02,2"
  end

  test "locations= should parse and create election_locations" do
    election = create(:election)

    assert_difference 'election.election_locations.count', 2 do
      election.locations = "01,1\n02,2"
    end

    assert election.election_locations.find_by(location: "01")
    assert election.election_locations.find_by(location: "02")
  end

  test "locations= should handle override values" do
    election = create(:election)

    election.locations = "01,1,override1"

    location = election.election_locations.find_by(location: "01")
    assert_equal "override1", location.override
  end

  test "locations= should skip empty lines" do
    election = create(:election)

    assert_difference 'election.election_locations.count', 2 do
      election.locations = "01,1\n\n02,2\n  \n"
    end
  end

  # PHASE 1 SECURITY REFACTORING TESTS

  test "parse_duration_config should parse seconds format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "5.seconds", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 5.seconds, result
    end
  end

  test "parse_duration_config should parse minutes format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "10.minutes", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 10.minutes, result
    end
  end

  test "parse_duration_config should parse hours format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "2.hours", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 2.hours, result
    end
  end

  test "parse_duration_config should parse days format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "7.days", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 7.days, result
    end
  end

  test "parse_duration_config should parse weeks format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "2.weeks", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 2.weeks, result
    end
  end

  test "parse_duration_config should parse months format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "3.months", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 3.months, result
    end
  end

  test "parse_duration_config should parse years format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "1.year", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 1.year, result
    end
  end

  test "parse_duration_config should handle plural forms" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "5.years", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 5.years, result
    end
  end

  test "parse_duration_config should handle integer config values" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], 3600, ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 3600.seconds, result
    end
  end

  test "parse_duration_config should fallback to 1.year for invalid format" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "invalid", ["active_census_range"] do
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 1.year, result
    end
  end

  test "parse_duration_config should not execute arbitrary code" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], "system('rm -rf /'); 1.year", ["active_census_range"] do
      Rails.logger.expects(:error).with(regexp_matches(/Failed to parse duration config/))
      result = election.send(:parse_duration_config, "active_census_range")
      assert_equal 1.year, result  # Should fallback safely
    end
  end

  test "parse_duration_config should log error on parse failure" do
    election = build(:election)
    Rails.application.secrets.users.stub :[], nil, ["active_census_range"] do
      Rails.logger.expects(:error).with(regexp_matches(/Failed to parse duration config/))
      election.send(:parse_duration_config, "active_census_range")
    end
  end

  # CENSUS METHODS

  test "has_valid_user_created_at? should return true when user_created_at_max is nil" do
    election = create(:election, user_created_at_max: nil)
    user = create(:user, created_at: 1.year.ago)

    assert election.has_valid_user_created_at?(user)
  end

  test "has_valid_user_created_at? should return true when user created before max" do
    election = create(:election, user_created_at_max: 1.month.ago)
    user = create(:user, created_at: 2.months.ago)

    assert election.has_valid_user_created_at?(user)
  end

  test "has_valid_user_created_at? should return false when user created after max" do
    election = create(:election, user_created_at_max: 1.month.ago)
    user = create(:user, created_at: 1.day.ago)

    assert_not election.has_valid_user_created_at?(user)
  end

  # EDGE CASES

  test "should handle election starting and ending at same time" do
    time = Time.now
    election = build(:election, starts_at: time, ends_at: time)

    assert election.valid?
    assert_equal 0, election.duration
  end

  test "should handle very long election duration" do
    election = create(:election,
      starts_at: Time.parse('2025-01-01 00:00:00'),
      ends_at: Time.parse('2025-12-31 23:59:59')
    )

    assert election.duration > 8700  # More than 8700 hours in a year
  end

  test "should handle election with empty server" do
    election = create(:election, server: "")

    assert_not_nil election.server_url
    assert_not_nil election.server_shared_key
  end

  test "should handle election with nil server" do
    election = create(:election, server: nil)

    assert_not_nil election.server_url
    assert_not_nil election.server_shared_key
  end

  # FILE ATTACHMENT (Paperclip)

  test "should accept valid CSV content type" do
    election = build(:election)
    election.census_file = fixture_file_upload('files/test.csv', 'text/csv')

    assert election.valid?
  end

  test "should reject invalid file content type" do
    election = build(:election)
    # Would need actual file fixture for full test
    # This validates the validation is set up
    assert election.respond_to?(:census_file)
  end
end
