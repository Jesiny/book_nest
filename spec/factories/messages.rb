FactoryBot.define do
  factory :message do
    association :chat
    role { "user" }
    content { Faker::Lorem.paragraph }

    trait :assistant do
      role { "assistant" }
    end

    trait :system do
      role { "system" }
    end
  end
end
