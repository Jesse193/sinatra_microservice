require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'rack/cors'
require 'json'
require_relative '../models/user'
require_relative '../models/market'
require_relative '../serializers/user_serializer'
require_relative '../serializers/market_serializer'

use Rack::Cors do
  allow do
    origins 'http://localhost:3000'
    resource 'http://localhost:3000/*', headers: :any, methods: [:get, :post, :options]
  end
end

before do
  content_type :json
end

get '/markets' do 
  markets = Market.all
  json MarketSerializer.new(markets)
end

get '/markets/search' do 
  markets = Market.nearby_markets(params)
  json MarketSerializer.new(markets)
end

get '/markets/favorites' do 
  markets = Market.find(params[:market_ids])
  json MarketSerializer.new(markets)
end

get '/markets/:id' do 
  market = Market.find(params[:id])
  json MarketSerializer.new(market)
end

post '/api/users' do
  payload = JSON.parse(request.body.read)
  
  user = User.new(
    username: payload['username'],
    password: payload['password'] # mapped to password_digest automatically
  )

  if user.save
    status 201
    json(message: "User successfully registered", user_id: user.id)
  else
    status 422
    json(errors: user.errors.full_messages)
  end
end