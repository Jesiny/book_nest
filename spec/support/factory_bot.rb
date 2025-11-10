RSpec.configure do |config|
  # Allows using `create(:book)` instead of `FactoryBot.create(:book)`
  config.include FactoryBot::Syntax::Methods
end
