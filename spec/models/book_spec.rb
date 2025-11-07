require "rails_helper"

RSpec.describe Book, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_numericality_of(:rating).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5) }

    it "validates rating is in half steps" do
      book = build(:book, rating: 3.7)
      expect(book).not_to be_valid
      expect(book.errors[:rating]).to be_present
    end

    it "accepts valid half-step ratings" do
      0.step(5.0, 0.5).each do |rating|
        book = build(:book, rating: rating)
        expect(book).to be_valid
      end
    end

    it "rejects rating below 0" do
      book = build(:book, rating: -0.5)
      expect(book).not_to be_valid
      expect(book.errors[:rating]).to be_present
    end

    it "rejects rating above 5" do
      book = build(:book, rating: 5.5)
      expect(book).not_to be_valid
      expect(book.errors[:rating]).to be_present
    end

    it "accepts boundary ratings 0 and 5" do
      expect(build(:book, rating: 0.0)).to be_valid
      expect(build(:book, rating: 5.0)).to be_valid
    end

    it "validates date_finished is after date_started" do
      book = build(:book,
        date_started: Date.today,
        date_finished: Date.yesterday)
      expect(book).not_to be_valid
      expect(book.errors[:date_finished]).to be_present
    end

    it "accepts valid date range" do
      book = build(:book, :finished)
      expect(book).to be_valid
    end

    it "allows nil dates" do
      book = build(:book, date_started: nil, date_finished: nil)
      expect(book).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_one_attached(:cover) }
    it { is_expected.to have_one(:chat).dependent(:destroy) }
  end

  describe "enum status" do
    it "has tbr_status? method" do
      book = build(:book, status: :tbr)
      expect(book.tbr_status?).to be true
      expect(book.reading_status?).to be false
    end

    it "has reading_status? method" do
      book = build(:book, status: :reading)
      expect(book.reading_status?).to be true
      expect(book.tbr_status?).to be false
    end

    it "has finished_status? method" do
      book = build(:book, status: :finished)
      expect(book.finished_status?).to be true
      expect(book.tbr_status?).to be false
    end

    it "has dnf_status? method" do
      book = build(:book, status: :dnf)
      expect(book.dnf_status?).to be true
      expect(book.tbr_status?).to be false
    end
  end

  describe "callbacks" do
    it "initializes AI chat after creation" do
      model = build(:model)
      book = build(:book)
      allow(BookChatPrompt).to receive(:build).and_return("instructions")
      allow(RubyLLM.config).to receive(:default_model).and_return(model)
      allow_any_instance_of(Chat).to receive(:with_instructions)

      expect { book.save }.to change { Chat.count }.by(1)
      expect(BookChatPrompt).to have_received(:build).with(book.id)
    end
  end
end
