require 'rack'
require_relative '../config/environment'
require_relative '../app/controllers/password_resets_controller'

APP = Rack::Builder.new do
  map '/' do
    run MicroserviceApp
  end

  map '/api' do
    use MarketsController
    use PasswordResetsController
    run UsersController
  end
end.to_app
