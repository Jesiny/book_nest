FactoryBot.define do
  factory :chat do
    association :subject, factory: :book, strategy: :build
    association :model, factory: :model

    before(:create) do |chat|
      # Ensure the subject is saved if it's a new record
      chat.subject.save! if chat.subject.new_record?
    end
  end
end
