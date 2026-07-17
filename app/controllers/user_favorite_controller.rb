require 'sinatra'
require 'json'
require_relative '../services/json_web_token'

class UserFavoritesController < ApiBase

  configure do
    set :logging, true
  end

  before do
    content_type :json

    allowed_origins = (ENV['ALLOWED_ORIGINS'] || ENV['FRONTEND_ORIGIN'] || 'http://localhost:5173').split(',').map(&:strip).reject(&:empty?)
    origin = request.env['HTTP_ORIGIN'].to_s
    if allowed_origins.include?(origin)
      response.headers['Access-Control-Allow-Origin'] = origin
      response.headers['Access-Control-Allow-Credentials'] = 'true'
    end

    if request.body && request.body.respond_to?(:size) && request.body.size.to_i > 0
      request.body.rewind
      @payload = JSON.parse(request.body.read) rescue {}
    end
  end

  helpers do
    def authenticate_user!
      auth_header = request.env['HTTP_AUTHORIZATION']
      
      if auth_header.nil? || !auth_header.start_with?('Bearer ')
        halt 401, { error: "Access Denied: Missing or invalid token" }.to_json
      end

      token = auth_header.split(' ').last
      decoded = JsonWebToken.decode(token) rescue nil

      if decoded && decoded[:user_id]
        @current_user = User.find_by(id: decoded[:user_id])
      end

      if @current_user.nil?
        halt 401, { error: "Access Denied: Missing or invalid token" }.to_json
      end
    end
  end

  get '/api/protected_data' do
    authenticate_user!
    status 200
    { 
      message: "Protected data unlocked!", 
      secret_data: "This data is unlocked for #{@current_user.email}." 
    }.to_json
  end

  options '*' do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization"
    status 200
  end
  
  post '/api/favorites' do
    authenticate_user!
    user_favorite = UserFavorite.new(user_id: @current_user.id, market_id: @payload['market'])
    if user_favorite.save
      status 201
      { message: "Favorite added successfully", favorite: { user_id: user_favorite.user_id, market_id: user_favorite.market_id } }.to_json
    else
      status 422
      { errors: user_favorite.errors.full_messages }.to_json
    end
  end
end