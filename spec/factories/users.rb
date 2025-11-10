FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username(specifier: 3..20) }
    password { Faker::Internet.password(min_length: 6) }
  end
end
