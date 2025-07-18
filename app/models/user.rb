class User < ApplicationRecord
   has_secure_password

   has_many :posts, dependent: :destroy
   has_many :comments, dependent: :destroy

   validates :name, :email, presence: true
   validates :email, uniqueness: true
   normalizes :email, with: ->(e) { e.strip.downcase }
end
