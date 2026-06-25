require 'sinatra' 
require 'json' 
require_relative '../services/json_web_token' 

class UsersController < Sinatra::Base
  configure do
    set :logging, true
  end

  before do
    content_type :json
    
    response.headers['Access-Control-Allow-Origin'] = 'http://localhost:5173'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization'
    response.headers['Access-Control-Allow-Credentials'] = 'true'

    @payload = {}
    if request.env['REQUEST_METHOD'] != 'GET' && request.body
      begin
        body_text = request.body.read
        unless body_text.to_s.strip.empty?
          @payload = JSON.parse(body_text)
        end
      rescue JSON::ParserError
        @payload = {}
      ensure
        request.env['rack.input'] = StringIO.new(body_text || '')
      end
    end
  end


  options '*' do
    status 200
  end

  helpers do
    def authenticate_user!
      auth_header = request.env['HTTP_AUTHORIZATION']
      if auth_header.nil? || !auth_header.start_with?('Bearer ')
        halt 401, { error: "Access Denied: Missing or invalid token" }.to_json
      end

      token = auth_header.split(' ').last
      decoded = JsonWebToken.decode(token) rescue nil
      
      if decoded && (decoded[:user_id] || decoded['user_id'])
        user_id = decoded[:user_id] || decoded['user_id']
        @current_user = User.find_by(id: user_id)
      end

      if @current_user.nil?
        halt 401, { error: "Access Denied: Missing or invalid token" }.to_json
      end
    end
  end

  get '/protected_data' do 
    authenticate_user! 
    status 200 
    { message: "Protected data unlocked!", secret_data: "This data is unlocked for #{@current_user.email}." }.to_json 
  end 

  post '/favorites' do
    authenticate_user!
    
    user_favorite = UserFavorite.new(
      user_id: @current_user.id, 
      market_id: @payload['market']
    )
    
    if user_favorite.save
      status 201
      user_favorite.to_json
    else
      status 422
      { errors: user_favorite.errors.full_messages }.to_json
    end
  end

  get '/favorites' do
    authenticate_user!
  
    user_favorites = @current_user.user_favorites.includes(:market)
    
    market_records = user_favorites.map(&:market).compact
    
    status 200
    json MarketSerializer.new(market_records)
  end

  delete '/favorites/:id' do
    authenticate_user!
    
    favorite = @current_user.user_favorites.find_by(market_id: params[:id].to_s)

    if favorite
      favorite.destroy
      status 200
      { message: "Successfully removed from favorites" }.to_json
    else
      status 404
      { error: "No favorite record found matching string ID: #{params[:id]}" }.to_json
    end
  end




  post '/register' do 
    user = User.new( 
      email: @payload['email'], 
      password: @payload['password'] 
    ) 
    if user.save 
      status 201 
      { message: "User successfully registered", user_id: user.id }.to_json 
    else 
      status 422 
      { errors: user.errors.full_messages }.to_json 
    end 
  rescue => e 
    status 422 
    { errors: [e.message] }.to_json 
  end 

  post '/login' do 
    user = User.find_by(email: @payload['email']) 
    if user && user.authenticate(@payload['password']) 
      token = JsonWebToken.encode(user_id: user.id) 
      status 200 
      { message: "Authentication successful", token: token }.to_json 
    else 
      status 401 
      { error: "Invalid email or password credentials" }.to_json 
    end 
  end 
end
