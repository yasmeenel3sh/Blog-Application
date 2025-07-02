class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: true
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  validates :tags, length: { minimum: 1, message: "must have at least one tag" }

end
