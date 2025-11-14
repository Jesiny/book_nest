require "rails_helper"

RSpec.describe "Books", type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group, user: user) }

  before do
    sign_in user, scope: :user

    allow(BookChatPrompt).to receive(:build).and_return("instructions")
    allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
    allow_any_instance_of(Chat).to receive(:with_instructions)
  end

  describe "GET /groups/:group_id/books/:id" do
    let(:book) { create(:book, group: group) }

    it "returns http success" do
      get group_book_path(group_id: group, id: book)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("#{ERB::Util.html_escape(book.title)}</h1>")
    end

    it "prevents access to other user's book" do
      other_book = create(:book)

      get group_book_path(group_id: other_book.group, id: other_book)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /groups/:group_id/books/new" do
    it "returns http success" do
      get new_group_book_path(group_id: group)
      expect(response).to have_http_status(:success)
    end

    it "prevents access to other user's group" do
      other_group = create(:group)

      get new_group_book_path(group_id: other_group)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /groups/:group_id/books" do
    context "with valid parameters" do
      let(:valid_params) do
        { book: attributes_for(:book) }
      end

      it "creates a new book" do
        expect {
          post group_books_path(group_id: group), params: valid_params
        }.to change(Book, :count).by(1)
      end

      it "redirects to the created book" do
        post group_books_path(group_id: group), params: valid_params
        expect(response).to redirect_to(group_book_path(group, Book.last))
      end

      it "associates book with group" do
        post group_books_path(group_id: group), params: valid_params
        expect(Book.last.group).to eq(group)
      end

      it "prevents creation in other user's group" do
        other_group = create(:group)

        post group_books_path(group_id: other_group), params: valid_params
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { book: attributes_for(:book, title: "") }
      end

      it "does not create a new book" do
        expect {
          post group_books_path(group_id: group), params: invalid_params
        }.not_to change(Book, :count)
      end

      it "renders new template with unprocessable entity status" do
        post group_books_path(group_id: group), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /groups/:group_id/books/:id/edit" do
    let(:book) { create(:book, group: group) }

    it "returns http success" do
      get edit_group_book_path(group_id: group, id: book)
      expect(response).to have_http_status(:success)
    end

    it "prevents access to other user's book" do
      other_book = create(:book)

      get edit_group_book_path(group_id: other_book.group, id: other_book)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /groups/:group_id/books/:id" do
    let(:book) { create(:book, group: group) }

    context "with valid parameters" do
      let(:valid_params) do
        { book: attributes_for(:book) }
      end

      it "updates the book" do
        patch group_book_path(group_id: group, id: book), params: valid_params
        book.reload
        valid_params[:book][:status] = valid_params[:book][:status].to_s

        expect(book).to have_attributes(valid_params[:book])
      end

      it "redirects to the book" do
        patch group_book_path(group_id: group, id: book), params: valid_params
        expect(response).to redirect_to(group_book_path(group, book))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { book: attributes_for(:book, title: "") }
      end

      it "does not update the book" do
        expect {
          patch group_book_path(group_id: group, id: book), params: invalid_params
        }.not_to change { book.reload }
      end

      it "renders edit template with unprocessable entity status" do
        patch group_book_path(group_id: group, id: book), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE /groups/:group_id/books/:id" do
    let!(:book) { create(:book, group: group) }

    it "destroys the book" do
      expect {
        delete group_book_path(group_id: group, id: book)
      }.to change(Book, :count).by(-1)
    end

    it "redirects to group page" do
      delete group_book_path(group_id: group, id: book)
      expect(response).to redirect_to(group_path(group))
    end

    it "prevents deletion of other user's book" do
      other_book = create(:book)
      delete group_book_path(group_id: other_book.group, id: other_book)

      expect(response).to have_http_status(:not_found)
    end
  end
end
