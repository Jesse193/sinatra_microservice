require 'spec_helper'

RSpec.describe UserFavorite, type: :model do
  describe 'model initialization' do
    it 'initializes' do
      user = create(:user, email: 'email@email.com', name: 'John Doe', password: 'Pa55w0!rdis5ecureandlong')
      market = create(:market)
      user_favorite = UserFavorite.new(user: user, market: market)
      expect(user_favorite).to be_a(UserFavorite)
      expect(user_favorite.user).to eq(user)
      expect(user_favorite.market).to eq(market)
    end
  end
end