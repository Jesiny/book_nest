require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:username) }

    it "validates uniqueness of username case-insensitively" do
      user1 = create(:user, username: "TestUser", email: "test1@example.com")
      user2 = build(:user, username: "testuser", email: "test2@example.com")
      expect(user2).not_to be_valid
      expect(user2.errors[:username]).to be_present
    end

    it "validates uniqueness of email case-insensitively" do
      user1 = create(:user, email: "Test@Example.com", username: "user1")
      user2 = build(:user, email: "test@example.com", username: "user2")
      expect(user2).not_to be_valid
      expect(user2.errors[:email]).to be_present
    end

    it "validates email format" do
      user = build(:user, email: "invalid-email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "accepts valid email format" do
      user = build(:user, email: "valid@example.com")
      expect(user).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:groups).dependent(:destroy) }
    it { is_expected.to have_many(:books).through(:groups) }
    it { is_expected.to have_one_attached(:avatar) }
  end

  describe "Devise modules" do
    it "is database authenticatable" do
      user = create(:user, password: "password123")
      expect(user.valid_password?("password123")).to be true
      expect(user.valid_password?("wrong_password")).to be false
    end

    it "is registerable" do
      expect(User.devise_modules).to include(:registerable)
    end

    it "is recoverable" do
      expect(User.devise_modules).to include(:recoverable)
    end

    it "is rememberable" do
      expect(User.devise_modules).to include(:rememberable)
    end

    it "is validatable" do
      expect(User.devise_modules).to include(:validatable)
    end
  end
end
