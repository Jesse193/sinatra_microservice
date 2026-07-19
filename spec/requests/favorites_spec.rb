require './spec/spec_helper.rb'

RSpec.describe 'Markets', type: :request do
  before(:each) do
    @market_1 = create(:market)
    @market_2 = create(:market)
    @market_3 = create(:market)
    @market_4 = create(:market)
    @market_5 = create(:market)
  end

  describe 'find favorites' do
    it 'gets users favorites' do

      user = create(:user, email: 'johndoe@example.com', name: 'John Doe', password: 'G00d143!')

      payload = {
        email: 'johndoe@example.com',
        password: 'G00d143!'
      }

      post '/api/login', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

      token = JSON.parse(last_response.body)['token']

      payload = {
        user: user.id,
        market: @market_1.id
      }

      post '/api/favorites', payload.to_json, {
        'CONTENT_TYPE' => 'application/json',
        'HTTP_AUTHORIZATION' => "Bearer #{token}"
      }

      get '/api/favorites',  {}, { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }

      expect(last_response).to be_successful
      expect(user.reload.favorite_markets).to include(@market_1)
      expect(user.reload.favorite_markets).not_to include(@market_2)
    end
  end
end