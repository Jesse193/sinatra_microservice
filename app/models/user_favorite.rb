class UserFavorite < ActiveRecord::Base
  self.table_name = 'users_favorites'

  belongs_to :user
  belongs_to :market

  validates :user_id, presence: true
  validates :market_id, presence: true
  validates :user_id, uniqueness: { scope: :market_id, message: "you've already favorited this market" }
end