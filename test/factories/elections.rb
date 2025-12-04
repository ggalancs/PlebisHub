# frozen_string_literal: true

FactoryBot.define do
  factory :election do
    sequence(:title) { |n| "Election #{n}" }
    sequence(:agora_election_id) { |n| n }
    starts_at { 1.day.ago }
    ends_at { 1.day.from_now }
    scope { 0 } # Estatal
    election_type { :nvotes }
    server { 'default' }
    voter_id_template { '%<secret_key_base>s:%<user_id>s:%<election_id>s:%<scoped_agora_election_id>s' }

    # FlagShihTzu flags (all false by default)
    flags { 0 }

    trait :with_sms_check do
      flags { 1 } # requires_sms_check
    end

    trait :show_on_index do
      flags { 2 }
    end

    trait :ignore_multiple_territories do
      flags { 4 }
    end

    trait :requires_vatid_check do
      flags { 8 }
    end

    trait :active do
      starts_at { 1.hour.ago }
      ends_at { 1.hour.from_now }
    end

    trait :upcoming do
      starts_at { 6.hours.from_now }
      ends_at { 1.day.from_now }
    end

    trait :finished do
      starts_at { 3.days.ago }
      ends_at { 1.day.ago }
    end

    trait :recently_finished do
      starts_at { 2.days.ago }
      ends_at { 1.hour.ago }
    end

    trait :future do
      starts_at { 2.days.from_now }
      ends_at { 3.days.from_now }
    end

    trait :external do
      election_type { :external }
    end

    trait :paper do
      election_type { :paper }
    end

    trait :municipal do
      scope { 3 }
    end

    trait :circles do
      scope { 6 }
    end
  end
end
