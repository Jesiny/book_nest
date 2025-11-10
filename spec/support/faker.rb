RSpec.configure do |config|
  config.before(:suite) do
    Faker::UniqueGenerator.clear
  end
end
