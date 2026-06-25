require 'sinatra'
require 'bundler'
Bundler.require

require File.expand_path('../config/environment', __FILE__)

map '/' do
  run MicroserviceApp
end

map '/api' do
  use MarketsController
  run UsersController
end
