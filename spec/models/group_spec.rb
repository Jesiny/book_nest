require "rails_helper"

RSpec.describe Group, type: :model do
  subject { create(:group) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:books).dependent(:destroy) }
  end

  describe "uniqueness validation" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "allows same name for different users" do
      create(:group, user: user, name: "My Group")
      group = build(:group, user: other_user, name: "My Group")
      expect(group).to be_valid
    end

    it "prevents duplicate names for same user" do
      group = create(:group, user: user, name: "My Group")
      duplicate = group.dup
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end
  end
end
