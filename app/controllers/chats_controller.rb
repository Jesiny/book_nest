class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :show ]
  before_action :set_book, only: [ :show ]
  before_action :set_chat, only: [ :show ]

  def index
    @chats = Chat.order(created_at: :desc)
  end

  def new
    @chat = Chat.new
    @selected_model = params[:model]
  end

  def create
    return unless prompt.present?

    @chat = Chat.create!(model: model)
    ChatResponseJob.perform_later(@chat.id, prompt)

    redirect_to @chat, notice: "Chat was successfully created."
  end

  def show
    @message = @chat.messages.build
  end

  private

  def set_group
    @group = current_user.groups.find(params[:group_id])
  end

  def set_book
    @book = @group.books.find(params[:book_id])
  end

  def set_chat
    @chat = @book.chat
  end

  def model
    params[:chat][:model].presence
  end

  def prompt
    params[:chat][:prompt]
  end
end
