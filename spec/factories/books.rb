FactoryBot.define do
  factory :book do
    transient do
      user { nil }
    end

    after(:build) do |book, evaluator|
      book.group ||= build(:group, user: evaluator.user || build(:user))
    end

    title { Faker::Book.title }
    author { Faker::Book.author }
    resume { Faker::Lorem.paragraph }
    rating { [ 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 ].sample }
    status { :tbr }
    date_started { nil }
    date_finished { nil }
    review { Faker::Lorem.paragraph }

    trait :reading do
      status { :reading }
      date_started { Faker::Date.backward(days: 30) }
    end

    trait :finished do
      status { :finished }
      date_started { Faker::Date.backward(days: 60) }
      date_finished { date_started + rand(1..30).days }
      rating { [ 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 ].sample }
    end

    trait :dnf do
      status { :dnf }
      date_started { Faker::Date.backward(days: 30) }
    end
  end
end
