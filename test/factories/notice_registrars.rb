FactoryBot.define do
  factory :notice_registrar, class: 'PlebisCms::NoticeRegistrar' do
    sequence(:registration_id) { |n| "REG#{n.to_s.rjust(6, '0')}" }
    status { true }

    trait :inactive do
      status { false }
    end

    trait :pending do
      status { nil }
    end
  end
end
