FactoryBot.define do
  factory :vote_circle do
    sequence(:name) { |n| "Circle #{n}" }
    sequence(:code) { |n| "TM28001#{n.to_s.rjust(2, '0')}" }
    kind { :municipal }
    country_code { "ES" }
    autonomy_code { "a_13" }
    province_code { "p_28" }
    town { "m_28_079" }

    trait :interno do
      kind { :interno }
    end

    trait :barrial do
      kind { :barrial }
      code { "TB28001001" }
    end

    trait :municipal do
      kind { :municipal }
      code { "TM28001001" }
    end

    trait :comarcal do
      kind { :comarcal }
      code { "TC28001001" }
    end

    trait :exterior do
      kind { :exterior }
      code { "00" }
      country_code { "FR" }
    end
  end
end
