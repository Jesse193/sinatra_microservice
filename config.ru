require 'sinatra'
require 'bundler'
Bundler.require

require_relative 'config/environment'
require_relative 'app/controllers/password_resets_controller'

map '/' do
  run MicroserviceApp
end

map '/api' do
  use MarketsController
  use PasswordResetsController
  run UsersController
end