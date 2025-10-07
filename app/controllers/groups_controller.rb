class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show, :edit, :update, :destroy ]

  def index
    @groups = current_user.groups.order(:name)
  end

  def show
    @books = @group.books.order(created_at: :desc)
  end

  def new
    @group = current_user.groups.new
  end

  def create
    @group = current_user.groups.new(group_params)
    if @group.save
      redirect_to @group, notice: t("groups.notices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: t("groups.notices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path, notice: t("groups.notices.destroyed")
  end

  private

  def set_group
    @group = current_user.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end
end
