class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 8 }, on: :create

  has_many :user_favorites, dependent: :destroy
  has_many :favorite_markets, through: :user_favorites, source: :market
end
