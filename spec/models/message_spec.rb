require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:chat) }
    it { is_expected.to have_many_attached(:attachments) }
  end

  describe "validations" do
    it "requires role" do
      message = build(:message, role: nil)
      expect(message).not_to be_valid
    end
  end

  describe "acts_as_message" do
    it "belongs to chat" do
      allow(BookChatPrompt).to receive(:build).and_return("instructions")
      allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
      allow_any_instance_of(Chat).to receive(:with_instructions)

      chat = create(:chat)
      message = create(:message, chat: chat)
      expect(message.chat).to eq(chat)
    end
  end

  describe "#broadcast_append_chunk" do
    it "broadcasts chunk content" do
      allow(BookChatPrompt).to receive(:build).and_return("instructions")
      allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
      allow_any_instance_of(Chat).to receive(:with_instructions)

      message = create(:message)
      allow(message).to receive(:broadcast_append_to)

      message.broadcast_append_chunk("chunk content")

      expect(message).to have_received(:broadcast_append_to).with(
        "chat_#{message.chat_id}",
        target: "message_#{message.id}_content",
        partial: "messages/content",
        locals: { content: "chunk content" }
      )
    end
  end
end
