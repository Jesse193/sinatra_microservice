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

require "capybara/rspec"
require "capybara-playwright-driver"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: ENV["HEADFUL"] != "1"
  )
end

Capybara.default_driver = :playwright
Capybara.javascript_driver = :playwright

Capybara.run_server = false
Capybara.app_host = "http://127.0.0.1:5173"

require "socket"
require "timeout"

def wait_for_port(port, timeout: 15)
  Timeout.timeout(timeout) do
    loop do
      TCPSocket.new("127.0.0.1", port).close
      break
    rescue Errno::ECONNREFUSED
      sleep 0.2
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  def app
    APP
  end

  config.before(:suite) do
    db_config_path = File.expand_path('../../config/database.yml', __FILE__)
    db_config = YAML.safe_load(
      ERB.new(File.read(db_config_path)).result,
      aliases: true
    )['test']
    
    ActiveRecord::Base.establish_connection(db_config)

    User.reset_column_information rescue nil
    Market.reset_column_information rescue nil
    UserFavorite.reset_column_information rescue nil

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, { except: %w[ar_internal_metadata schema_migrations] })

    FactoryBot.definition_file_paths = [
    File.expand_path('factories', __dir__)
    ]

    FactoryBot.find_definitions
  end

  config.before(:each, type: :feature) do
    unless $sinatra_pid && $vite_pid

      puts "Starting Sinatra..."

      $sinatra_pid = spawn(
        {"RACK_ENV" => "test", "SINATRA_ENV" => "test"},
        "bundle exec rackup -p 9292",
        chdir: ".",
        out: $stdout,
        err: $stderr
      )

      puts "Starting Vite..."
      
      frontend_dir = ENV.fetch("FRONTEND_DIR", "../food_haven_react_fe")

      $vite_pid = spawn(
        "npm",
        "run",
        "dev",
        "--",
        "--host",
        "127.0.0.1",
        "--port",
        "5173",
        chdir: frontend_dir,
        out: $stdout,
        err: $stderr
      )

      wait_for_port(9292)
      wait_for_port(5173)

      puts "Servers ready."
    end
  end

  config.before(:each, type: :request) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each, type: :request) do
    DatabaseCleaner.clean
  end

  config.before(:each, type: :model) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each, type: :model) do
    DatabaseCleaner.clean
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, type: :request) do
    DatabaseCleaner.strategy = :transaction
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    [$sinatra_pid, $vite_pid].compact.each do |pid|
      begin
        Process.kill("TERM", pid)
        Process.wait(pid)
      rescue Errno::ESRCH, Errno::ECHILD
      end
    end
  end
end
