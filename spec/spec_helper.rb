ENV["RACK_ENV"] = "test"

require 'rspec'
require 'rack/test'

require 'bundler'
Bundler.require(:default, :test)


require File.expand_path('../../config/environment.rb', __FILE__)

require 'factory_bot'

require 'simplecov'
SimpleCov.start


def app
  Microservice
end


RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  config.include FactoryBot::Syntax::Methods
  
  DatabaseCleaner.strategy = :truncation
  
  config.before(:each) do
    DatabaseCleaner.clean
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
  config.before(:suite) do
    FactoryBot.definition_file_paths = [File.expand_path('../spec/factories', __dir__)]
    
    FactoryBot.find_definitions
  end
end
