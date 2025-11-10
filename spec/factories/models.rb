FactoryBot.define do
  factory :model do
    name { RubyLLM.config.default_model }
    provider { Faker::Lorem.word }
    model_id { Faker::Lorem.word }
    context_window { Faker::Number.between(from: 1000, to: 100000) }
    max_output_tokens { Faker::Number.between(from: 100, to: 10000) }
    capabilities { [] }
    modalities { {} }
    metadata { {} }
    pricing { {} }
  end
end
