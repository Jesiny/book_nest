require "rails_helper"

RSpec.describe "Groups", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /groups" do
    it "returns http success" do
      get groups_path
      expect(response).to have_http_status(:success)
    end

    it "displays user's groups" do
      user_groups = create_list(:group, 2, user: user)
      other_user_group = create(:group)

      get groups_path

      user_groups.each do |group|
        expect(response.body).to include("#{group.name}</h2>")
      end
      expect(response.body).not_to include("#{other_user_group.name}</h2>")
    end

    it "requires authentication" do
      sign_out :user
      get groups_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /groups/:id" do
    let(:group) { create(:group, user: user) }

    it "returns http success" do
      get group_path(id: group)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("#{group.name}</h1>")
    end

    it "displays group books" do
      allow(BookChatPrompt).to receive(:build).and_return("instructions")
      allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
      allow_any_instance_of(Chat).to receive(:with_instructions)
      books = create_list(:book, 2, group: group)
      other_group_book = create(:book, user: user)

      get group_path(id: group)

      books.each do |book|
        expect(response.body).to include("#{book.title}</h3>")
      end
      expect(response.body).not_to include("#{other_group_book.title}</h3>")
    end

    it "prevents access to other user's group" do
      other_group = create(:group)
      get group_path(id: other_group)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /groups/new" do
    it "returns http success" do
      get new_group_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /groups" do
    context "with valid parameters" do
      let(:valid_params) do
        { group: attributes_for(:group) }
      end

      it "creates a new group" do
        expect {
          post groups_path, params: valid_params
        }.to change(Group, :count).by(1)
      end

      it "redirects to the created group" do
        post groups_path, params: valid_params
        group = Group.last
        expect(response).to redirect_to(group_path(group))
      end

      it "sets the current user as owner" do
        post groups_path, params: valid_params
        group = Group.last
        expect(group.user).to eq(user)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { group: attributes_for(:group, name: "") }
      end

      it "does not create a new group" do
        expect {
          post groups_path, params: invalid_params
        }.not_to change(Group, :count)
      end

      it "renders new template with unprocessable entity status" do
        post groups_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /groups/:id/edit" do
    let(:group) { create(:group, user: user) }

    it "returns http success" do
      get edit_group_path(id: group)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("value=\"#{group.name}\"")
    end

    it "prevents access to other user's group" do
      other_group = create(:group)

      get edit_group_path(id: other_group)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /groups/:id" do
    let(:group) { create(:group, user: user) }

    context "with valid parameters" do
      let(:valid_params) do
        { group: attributes_for(:group) }
      end

      it "updates the group" do
        patch group_path(id: group), params: valid_params
        group.reload

        expect(group).to have_attributes(valid_params[:group])
      end

      it "redirects to the group" do
        patch group_path(id: group), params: valid_params
        expect(response).to redirect_to(group_path(group))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { group: attributes_for(:group, name: "") }
      end

      it "does not update the group" do
        expect {
          patch group_path(id: group), params: invalid_params
        }.not_to change { group.reload }
      end

      it "renders edit template with unprocessable entity status" do
        patch group_path(id: group), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE /groups/:id" do
    let!(:group) { create(:group, user: user) }

    it "destroys the group" do
      expect {
        delete group_path(id: group)
      }.to change(Group, :count).by(-1)
    end

    it "redirects to groups index" do
      delete group_path(id: group)
      expect(response).to redirect_to(groups_path)
    end

    it "prevents deletion of other user's group" do
      other_group = create(:group)
      delete group_path(id: other_group)

      expect(response).to have_http_status(:not_found)
    end
  end
end
