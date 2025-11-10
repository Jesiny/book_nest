require "rails_helper"

RSpec.describe BookChatPrompt, type: :service do
  describe ".build" do
    before do
      allow_any_instance_of(Book).to receive(:initialize_ai_chat)
    end

    let(:book) { create(:book) }

    it "returns a prompt string" do
      prompt = described_class.build(book.id)
      expect(prompt).to be_a(String)
      expect(prompt).not_to be_empty
    end

    it "includes the book title in the prompt" do
      prompt = described_class.build(book.id)
      expect(prompt).to include(book.title)
    end

    it "includes the book author in the prompt" do
      prompt = described_class.build(book.id)
      expect(prompt).to include(book.author)
    end

    it "includes instructions about being an AI reading companion" do
      prompt = described_class.build(book.id)
      expect(prompt).to include("AI reading companion")
      expect(prompt).to include("literary assistant")
    end

    it "includes instructions about summary writing" do
      prompt = described_class.build(book.id)
      expect(prompt).to include("help to **write or improve a résumé (summary)**")
    end

    it "includes instructions about review writing" do
      prompt = described_class.build(book.id)
      expect(prompt).to include("help to **write or refine a review**")
    end

    it "includes instructions about language matching" do
      prompt = described_class.build(book.id)
      expect(prompt).to include("Always reply in the same language as the user's message.")
    end

    it "includes only book topic" do
      prompt = described_class.build(book.id)
      expect(prompt).to include("You must always base your answers on this specific book — its characters, themes, and plot, or other authors's book.")
    end

    it "raises error if book does not exist" do
      not_saved_book = build(:book)
      expect {
        described_class.build(not_saved_book.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
