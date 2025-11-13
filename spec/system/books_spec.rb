require "rails_helper"

RSpec.describe "Book management", type: :system do
  let(:user) { create(:user) }
  let(:group) { create(:group, user: user) }

  before do
    sign_in user, scope: :user

    allow(BookChatPrompt).to receive(:build).and_return("instructions")
    allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
    allow_any_instance_of(Chat).to receive(:with_instructions)
  end

  describe "Adding a book" do
    let(:book_arg) { build(:book, group: group, status: :reading) }

    it "allows user to add a new book to a group" do
      visit group_path(id: group)

      click_on I18n.t("groups.show.add_first")
      expect(page).to have_current_path(new_group_book_path(I18n.locale, group))

      fill_in "Title", with: book_arg.title
      fill_in "Author", with: book_arg.author
      fill_in "Resume", with: book_arg.resume
      fill_in "Review", with: book_arg.review
      select book_arg.status.humanize, from: "Status"

      page.execute_script(%Q{
        const input = document.querySelector('[data-rating-target="input"]');
        input.value = #{book_arg.rating};
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      })

      click_on I18n.t("common.save")

      expect(page).to have_content(book_arg.title)
      expect(page).to have_content(book_arg.author)
      expect(page).to have_content(book_arg.resume)
      expect(page).to have_content(book_arg.review)
      expect(page).to have_content(I18n.t("activerecord.attributes.book.status_#{book_arg.status}"))
      expect(page).to have_content(book_arg.rating)
      expect(Book.count).to eq(1)
      book = Book.last
      expect(book.group).to eq(group)
    end

    it "shows validation errors when creating with invalid data" do
      book_arg.title = ""
      visit new_group_book_path(group_id: group)

      fill_in "Title", with: book_arg.title
      fill_in "Author", with: book_arg.author
      fill_in "Resume", with: book_arg.resume
      fill_in "Review", with: book_arg.review
      select book_arg.status.humanize, from: "Status"

      page.execute_script(%Q{
        const input = document.querySelector('[data-rating-target="input"]');
        input.value = #{book_arg.rating};
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      })

      click_on I18n.t("common.save")

      expect(page).to have_current_path(new_group_book_path(group_id: group))
      expect(Book.count).to eq(0)
    end
  end

  describe "Editing a book" do
    let(:book) { create(:book, group: group) }
    let(:book_arg) { build(:book, group: group, status: :reading) }

    it "allows user to edit book details" do
      visit group_book_path(group_id: group, id: book)

      click_on I18n.t("common.edit")
      expect(page).to have_current_path(edit_group_book_path(I18n.locale, group, book))

      fill_in "Title", with: book_arg.title
      fill_in "Author", with: book_arg.author
      fill_in "Resume", with: book_arg.resume
      fill_in "Review", with: book_arg.review
      select book_arg.status.humanize, from: "Status"

      page.execute_script(%Q{
        const input = document.querySelector('[data-rating-target="input"]');
        input.value = #{book_arg.rating};
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      })

      click_on I18n.t("common.save")

      expect(page).to have_content(book_arg.title)
      expect(page).to have_content(book_arg.author)
      expect(page).to have_content(book_arg.resume)
      expect(page).to have_content(book_arg.review)
      expect(page).to have_content(I18n.t("activerecord.attributes.book.status_#{book_arg.status}"))
      expect(page).to have_content(book_arg.rating)
    end

    it "validates date_finished is after date_started" do
      visit edit_group_book_path(group_id: group, id: book)

      fill_in "Date started", with: Date.today.strftime("%Y-%m-%d")
      fill_in "Date finished", with: Date.yesterday.strftime("%Y-%m-%d")

      click_on I18n.t("common.save")

      expect(page).to have_content(I18n.t("activerecord.errors.models.book.attributes.date_finished.after_or_equal_to_start"))
    end
  end

  describe "Viewing books" do
    it "displays books in a group" do
      book1 = create(:book, group: group)
      book2 = create(:book, group: group)

      visit group_path(id: group)

      expect(page).to have_content(book1.title)
      expect(page).to have_content(book2.title)
    end

    it "allows viewing book details" do
      book = create(:book, group: group)

      visit group_book_path(group_id: group, id: book)

      expect(page).to have_content(book.title)
      expect(page).to have_content(book.author)
      expect(page).to have_content(book.resume)
    end
  end

  describe "Book status transitions" do
    let(:book) { create(:book, group: group, status: :tbr) }

    it "allows changing status from TBR to Reading" do
      visit edit_group_book_path(group_id: group, id: book)

      select :reading.to_s.humanize, from: "Status"

      click_on I18n.t("common.save")

      expect(page).to have_current_path(group_book_path(I18n.locale, group, book))
      book.reload
      expect(book.reading_status?).to be true
    end
  end
end
