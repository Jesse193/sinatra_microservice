require './spec/spec_helper.rb'

RSpec.describe 'Markets', type: :request do
  before(:each) do
    @market_1_id = create(:market).id
    @market_2_id = create(:market).id
    @market_3_id = create(:market).id
    @market_4_id = create(:market).id
    @market_5_id = create(:market).id
  end

  describe 'find favorites' do
    it 'gets users favorites' do

      user = create(:user, email: 'johndoe@example.com', name: 'John Doe', password: 'password123')
      market = create(:market)

      payload = {
        email: 'johndoe@example.com',
        password: 'password123'
      }

      post '/api/login', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

      token = JSON.parse(last_response.body)['token']

      payload = {
        user: user.id,
        market: market.id
      }

      post '/api/favorites', payload.to_json, {
        'CONTENT_TYPE' => 'application/json',
        'HTTP_AUTHORIZATION' => "Bearer #{token}"
      }

      get '/markets/favorites', market_ids: [market.id]

      expect(last_response).to be_successful
      expect(user.reload.favorite_markets).to include(market)
    end
  end
end