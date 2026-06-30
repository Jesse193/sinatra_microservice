class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 8 }, format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])/,
    message: "must include at least one lowercase letter, one uppercase letter, one number, and one special character" 
  }, 
  if: -> { password.present? }, on: :create

  has_many :user_favorites, dependent: :destroy
  has_many :favorite_markets, through: :user_favorites, source: :market
end
