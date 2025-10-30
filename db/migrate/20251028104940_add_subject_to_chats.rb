class AddSubjectToChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :chats, :subject, polymorphic: true, null: false, index: true
  end
end
