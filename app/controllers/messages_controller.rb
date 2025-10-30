class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :create ]
  before_action :set_book, only: [ :create ]
  before_action :set_chat

  def create
    return unless content.present?

    ChatResponseJob.perform_later(@chat.id, content)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @chat }
    end
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

  def content
    params[:message][:content]
  end
end
