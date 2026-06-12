require 'sinatra'
require 'json'
require_relative '../services/json_web_token'

class UsersController < Sinatra::Base
  configure do
    set :logging, true
  end

  before do
    content_type :json
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

  options '*' do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization"
    status 200
  end

  get '/api/protected_data' do
    authenticate_user!
    status 200
    { 
      message: "Protected data unlocked!", 
      secret_data: "This data is unlocked for #{@current_user.email}." 
    }.to_json
  end

  post '/api/register' do
    user = User.new(
      email: @payload['email'],
      password: @payload['password']
    )
    if user.save
      status 201
      { message: "User successfully registered", user_id: user.id }.to_json
    end
  rescue => e
    status 422
    { errors: [e.message] }.to_json
  end

  post '/api/login' do
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
