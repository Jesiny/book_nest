class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_book, only: [ :show, :edit, :update, :destroy ]

  def show
  end

  def new
    @book = @group.books.new
  end

  def create
    @book = @group.books.new(book_params)
    if @book.save
      attach_cover
      redirect_to [ @group, @book ], notice: t("books.notices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      attach_cover
      redirect_to [ @group, @book ], notice: t("books.notices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to group_path(@group), notice: t("books.notices.destroyed")
  end

  private

  def attach_cover
    @book.cover.attach(book_params[:cover]) if book_params[:cover].present?
  end

  def set_group
    @group = current_user.groups.find(params[:group_id])
  end

  def set_book
    @book = @group.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :resume, :rating, :status, :date_started, :date_finished, :review, :cover)
  end
end
