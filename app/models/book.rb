class Book < ApplicationRecord
  belongs_to :group

  has_one_attached :cover
  has_one :chat, as: :subject, dependent: :destroy

  enum :status, {
    tbr: "tbr",
    reading: "reading",
    finished: "finished",
    dnf: "dnf"
  }, suffix: true

  validates :title, :author, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: false

  validate :rating_in_half_steps
  validate :finished_after_started

  after_create :initialize_ai_chat

  private

  def rating_in_half_steps
    return if rating.nil?
    # ensure increments of 0.5
    errors.add(:rating, :invalid) unless ((rating * 2) % 1).zero?
  end

  def finished_after_started
    return if date_started.blank? || date_finished.blank?
    if date_finished < date_started
      errors.add(:date_finished, :after_or_equal_to_start)
    end
  end

  def initialize_ai_chat
    instructions = BookChatPrompt.build(id)
    chat = Chat.create!(
      model: RubyLLM.config.default_model,
      subject: self
    )

    chat.with_instructions(instructions)
  end
end
