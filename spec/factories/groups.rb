FactoryBot.define do
  factory :group do
    association :user
    name { Faker::Lorem.unique.word }
    description { Faker::Lorem.paragraph }
  end
end
