# frozen_string_literal: true

FactoryBot.define do
  factory :user_verification, class: 'PlebisVerification::UserVerification' do
    association :user
    status { :pending }
    terms_of_service { '1' } # Rails 7.2 requires "1" format for acceptance validation
    wants_card { false }

    # Skip validations for tests since we can't easily create actual image files
    to_create { |instance| instance.save(validate: false) }

    # Adjunta las dos fotos del documento: sin ellas el registro no pasa las
    # validaciones de presencia (front_vatid siempre, back_vatid salvo pasaporte)
    trait :with_photos do
      after(:build) do |verification|
        %i[front_vatid back_vatid].each do |attachment|
          verification.public_send(attachment).attach(
            io: StringIO.new('fake image content'),
            filename: "#{attachment}.png",
            content_type: 'image/png'
          )
        end
      end
    end

    trait :accepted do
      status { :accepted }
      processed_at { 1.day.ago }
    end

    trait :rejected do
      status { :rejected }
      processed_at { 1.day.ago }
      comment { 'Verification rejected' }
    end

    trait :issues do
      status { :issues }
      processed_at { 1.day.ago }
      comment { 'Issues found with verification' }
    end

    trait :accepted_by_email do
      status { :accepted_by_email }
      processed_at { 1.day.ago }
    end

    trait :discarded do
      status { :discarded }
      processed_at { 1.day.ago }
    end

    trait :paused do
      status { :paused }
      processed_at { 1.day.ago }
    end

    trait :with_card do
      wants_card { true }
      born_at { 25.years.ago }
    end

    trait :not_sended do
      wants_card { true }
      born_at { nil }
      status { :accepted }
    end
  end
end
