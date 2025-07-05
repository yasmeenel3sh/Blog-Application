class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, :body, presence: true
  validate :must_have_at_least_one_tag

  private

  def must_have_at_least_one_tag
    errors.add(:tags, "must have at least one tag") if tags.empty?
  end
  # validates :tags, length: { minimum: 1, message: "must have at least one tag" }
end
