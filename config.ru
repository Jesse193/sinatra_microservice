require 'sinatra'
require 'bundler'
Bundler.require

require File.expand_path('../config/environment', __FILE__)
require File.expand_path('../app/controllers/password_resets_controller', __FILE__)

map '/' do
  run MicroserviceApp
end

map '/api' do
  use MarketsController
  use PasswordResetsController
  run UsersController
end
