require "rails_helper"

RSpec.describe "Group management", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user, scope: :user
  end

  describe "Creating a group" do
    context "with valid parameters" do
      let(:group) { build(:group, user: user) }

      it "allows user to create a new group" do
        visit groups_path

        click_on I18n.t("groups.index.new_group")
        expect(page).to have_current_path(new_group_path(locale: I18n.locale))

        fill_in "Name", with: group.name
        fill_in "Description", with: group.description

        click_on I18n.t("common.save")

        expect(page).to have_content(group.name)
        expect(page).to have_content(group.description)
        expect(Group.count).to eq(1)
        expect(Group.last.user).to eq(user)
      end
    end

    it "shows validation errors when creating with invalid data" do
      visit new_group_path

      fill_in "Name", with: ""
      click_on I18n.t("common.save")

      expect(Group.count).to eq(0)
      expect(page).to have_current_path(new_group_path)
    end
  end

  describe "Viewing groups" do
    it "displays all user groups" do
      group1 = create(:group, user: user)
      group2 = create(:group, user: user)

      visit groups_path

      expect(page).to have_content(group1.name)
      expect(page).to have_content(group2.name)
    end

    it "does not display other users' groups" do
      other_group = create(:group)

      visit groups_path

      expect(page).not_to have_content(other_group.name)
    end
  end

  describe "Editing a group" do
    let(:group) { create(:group, user: user) }
    let(:updated_group) { build(:group, user: user) }

    it "allows user to edit group" do
      visit group_path(id: group)

      click_on I18n.t("common.edit")
      expect(page).to have_current_path(edit_group_path(locale: I18n.locale, id: group))

      fill_in "Name", with: updated_group.name
      fill_in "Description", with: updated_group.description

      click_on I18n.t("common.save")

      expect(page).to have_content(updated_group.name)
      expect(page).to have_content(updated_group.description)
    end
  end

  describe "Deleting a group" do
    let!(:group) { create(:group, user: user) }

    it "allows user to delete group" do
      visit groups_path

      expect(page).to have_content("Delete")

      click_on I18n.t("common.delete")
      page.accept_alert if page.driver.browser.respond_to?(:switch_to)

      expect(page).not_to have_content("Delete")
      expect(Group.count).to eq(0)
    end
  end
end
