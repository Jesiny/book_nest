require "rails_helper"

RSpec.describe ChatResponseJob, type: :job do
  before do
    allow(BookChatPrompt).to receive(:build).and_return("instructions")
    allow(RubyLLM.config).to receive(:default_model).and_return(build(:model))
    allow_any_instance_of(Chat).to receive(:with_instructions)
  end

  let!(:chat) { create(:chat) }
  let!(:message) { create(:message, chat: chat, role: "assistant") }


  describe "#perform" do
    it "calls ask on the chat with the content" do
      allow(chat).to receive(:ask).and_yield(double(content: "Response"))
      allow(Chat).to receive(:find).and_return(chat)

      described_class.new.perform(chat.id, message.content)

      expect(chat).to have_received(:ask).with(message.content)
    end

    it "broadcasts chunks when content is present" do
      chunk = double(content: "Chunk content")
      allow(chat).to receive(:ask).and_yield(chunk)
      allow(chat).to receive(:messages).and_return(double(last: message))
      allow(message).to receive(:broadcast_append_chunk)
      allow(Chat).to receive(:find).and_return(chat)

      described_class.new.perform(chat.id, message.content)

      expect(message).to have_received(:broadcast_append_chunk).with("Chunk content")
    end

    it "does not broadcast when chunk content is blank" do
      message = create(:message, chat: chat, role: "assistant")
      chunk = double(content: "")
      allow(chat).to receive(:ask).and_yield(chunk)
      allow(chat).to receive(:messages).and_return(double(last: message))
      allow(message).to receive(:broadcast_append_chunk)
      allow(Chat).to receive(:find).and_return(chat)

      described_class.new.perform(chat.id, message.content)

      expect(message).not_to have_received(:broadcast_append_chunk)
    end

    it "does not broadcast when chunk content is nil" do
      message = create(:message, chat: chat, role: "assistant")
      chunk = double(content: nil)
      allow(chat).to receive(:ask).and_yield(chunk)
      allow(chat).to receive(:messages).and_return(double(last: message))
      allow(message).to receive(:broadcast_append_chunk)
      allow(Chat).to receive(:find).and_return(chat)

      described_class.new.perform(chat.id, message.content)

      expect(message).not_to have_received(:broadcast_append_chunk)
    end

    it "handles multiple chunks" do
      chunk1 = double(content: "First chunk")
      chunk2 = double(content: "Second chunk")
      chunk3 = double(content: "Third chunk")
      allow(chat).to receive(:ask).and_yield(chunk1).and_yield(chunk2).and_yield(chunk3)
      allow(chat).to receive(:messages).and_return(double(last: message))
      allow(message).to receive(:broadcast_append_chunk)
      allow(Chat).to receive(:find).and_return(chat)

      described_class.new.perform(chat.id, message.content)

      expect(message).to have_received(:broadcast_append_chunk).with("First chunk")
      expect(message).to have_received(:broadcast_append_chunk).with("Second chunk")
      expect(message).to have_received(:broadcast_append_chunk).with("Third chunk")
    end

    context "not saved message" do
      let!(:not_saved_message) { build(:message, chat: chat,) }
      it "raises error if chat does not exist" do
        expect {
          described_class.new.perform(not_saved_message.id, not_saved_message.content)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
