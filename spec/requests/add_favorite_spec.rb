require 'spec_helper'

RSpec.describe 'User adds a favorite', type: :request do
  it 'adds a favorite' do
    user = create(:user, email: 'johndoe@example.com', name: 'John Doe', password: 'G00d143!')
    market = create(:market)

    payload = {
      email: 'johndoe@example.com',
      password: 'G00d143!'
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

    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['message']).to eq('Favorite added successfully')
    expect(JSON.parse(last_response.body)['favorite']['user_id']).to eq(user.id)
    expect(JSON.parse(last_response.body)['favorite']['market_id']).to eq(market.id)
  end
end