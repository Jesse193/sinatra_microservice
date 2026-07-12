require 'rack'
require_relative '../config/environment'
require_relative '../app/controllers/password_resets_controller'

APP = Rack::Builder.new do
  map '/' do
    run MicroserviceApp
  end

  map '/api' do
    run Rack::Cascade.new([
      MarketsController.new,
      PasswordResetsController.new,
      UsersController.new
    ])
  end
end.to_app
