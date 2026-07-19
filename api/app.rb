require 'rack'
require_relative '../config/environment'
require_relative '../app/controllers/password_resets_controller'

class BodyCache
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['rack.input']
      env['CACHED_RAW_BODY'] = env['rack.input'].read
      env['rack.input'].rewind if env['rack.input'].respond_to?(:rewind)
    end
    @app.call(env)
  end
end

APP = Rack::Builder.new do
  use BodyCache
  map '/api' do
    run Rack::Cascade.new([
      MarketsController.new,
      PasswordResetsController.new,
      UsersController.new
    ])
  end
end.to_app