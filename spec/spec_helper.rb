ENV["RACK_ENV"] = "test"
ENV["SINATRA_ENV"] = "test"

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'rack/test'
require 'bundler'
Bundler.require(:default, :test)

require File.expand_path('../../api/app.rb', __FILE__)
require 'factory_bot'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  def app
    APP
  end

  config.before(:suite) do
    db_config = YAML.safe_load_file(
      File.expand_path('../../config/database.yml', __FILE__), 
      aliases: true
    )['test']
    ActiveRecord::Base.establish_connection(db_config)

    User.reset_column_information rescue nil
    Market.reset_column_information rescue nil
    UserFavorite.reset_column_information rescue nil

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, { except: %w[ar_internal_metadata schema_migrations] })

    FactoryBot.definition_file_paths = [File.expand_path('../spec/factories', __dir__)]
    FactoryBot.find_definitions rescue nil
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
