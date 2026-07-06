require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib'
require 'rack/cors'
require 'json'
require_relative '../models/user'
require_relative '../models/market'
require_relative '../serializers/user_serializer'
require_relative '../serializers/market_serializer'
require_relative './user_controller'
require_relative './market_controller'
require_relative './user_favorite_controller'

class MicroserviceApp < Sinatra::Base
  def self.allowed_origins
    origins = ENV['ALLOWED_ORIGINS'] || ENV['FRONTEND_ORIGIN'] || 'http://localhost:5173'
    origins.split(',').map(&:strip).reject(&:empty?)
  end

  use Rack::Cors do
    allow do
      origins MicroserviceApp.allowed_origins
      resource '/*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options], credentials: true
    end
  end

  before do
    content_type :json
  end

  helpers do
    def authenticate_user!
      auth_header = request.env['HTTP_AUTHORIZATION']
      token = auth_header.split(' ').last if auth_header

      decoded = JsonWebToken.decode(token) if token
      @current_user = User.find_by(id: decoded[:user_id]) if decoded

      unless @current_user
        halt 401, { error: "Access Denied: Missing or invalid token" }.to_json
      end
    end
  end

  use MarketsController
  use UsersController
  use UserFavoritesController
end