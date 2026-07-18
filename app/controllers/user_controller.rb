require 'sinatra'
require 'json'
require_relative '../services/json_web_token'

class UsersController < ApiBase
  configure do
    set :logging, true
  end

  helpers do
    def authenticate_user!
      auth_header = request.env['HTTP_AUTHORIZATION']

      unless auth_header&.start_with?('Bearer ')
        halt 401, { error: 'Access Denied: Missing or invalid token' }.to_json
      end

      token = auth_header.split.last
      decoded = JsonWebToken.decode(token) rescue nil

      if decoded
        user_id = decoded[:user_id] || decoded['user_id']
        @current_user = User.find_by(id: user_id)
      end

      halt 401, { error: 'Access Denied: Missing or invalid token' }.to_json unless @current_user
    end
  end

  get '/protected_data' do
    authenticate_user!

    status 200
    {
      message: 'Protected data unlocked!',
      secret_data: "This data is unlocked for #{@current_user.email}."
    }.to_json
  end

  post '/favorites' do
    authenticate_user!

    favorite = UserFavorite.new(
      user_id: @current_user.id,
      market_id: @payload['market']
    )

    if favorite.save
      status 201
      favorite.to_json
    else
      status 422
      { errors: favorite.errors.full_messages }.to_json
    end
  end

  get '/favorites' do
    authenticate_user!

    markets = @current_user.user_favorites.includes(:market).map(&:market).compact

    status 200
    json MarketSerializer.new(markets)
  end

  delete '/favorites/:id' do
    authenticate_user!

    favorite = @current_user.user_favorites.find_by(market_id: params[:id])

    if favorite
      favorite.destroy
      status 200
      { message: 'Successfully removed from favorites' }.to_json
    else
      status 404
      { error: "No favorite record found matching market ID: #{params[:id]}" }.to_json
    end
  end

  post '/register' do
    user = User.new(
      email: @payload['email'],
      password: @payload['password']
    )

    if user.save
      token = JsonWebToken.encode(user_id: user.id)

      status 201
      {
        message: 'User successfully registered',
        token: token,
        user_id: user.id
      }.to_json
    else
      status 422
      { errors: user.errors.full_messages }.to_json
    end
  rescue StandardError => e
    logger.error("Registration error: #{e.class} - #{e.message}")

    status 500
    { error: 'Internal server error' }.to_json
  end

  post '/login' do
    user = User.find_by(email: @payload['email'])

    if user&.authenticate(@payload['password'])
      token = JsonWebToken.encode(user_id: user.id)

      status 200
      {
        message: 'Authentication successful',
        token: token
      }.to_json
    else
      status 401
      { error: 'Invalid email or password credentials' }.to_json
    end
  end
end