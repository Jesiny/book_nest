class Group < ApplicationRecord
  belongs_to :user
  has_many :books, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
