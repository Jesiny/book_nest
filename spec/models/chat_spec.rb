require "rails_helper"

RSpec.describe Chat, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:subject).optional(false) }

    it "belongs to polymorphic subject" do
      allow(BookChatPrompt).to receive(:build).and_return("instructions")
      allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
      allow_any_instance_of(Chat).to receive(:with_instructions)

      chat = build(:chat)
      book = chat.subject
      chat.save!

      expect(chat.subject).to eq(book)
      expect(chat.subject_type).to eq("Book")
      expect(chat.subject_id).to eq(book.id)
    end
  end

  describe "acts_as_chat" do
    it "has many messages" do
      allow(BookChatPrompt).to receive(:build).and_return("instructions")
      allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
      allow_any_instance_of(Chat).to receive(:with_instructions)

      chat = create(:chat)
      messages = create_list(:message, 2, chat: chat)

      expect(chat.messages).to match_array(messages)
    end
  end
end
