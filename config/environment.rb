require "bundler"
require 'dotenv'
Dotenv.load
Bundler.require

APP_ROOT = File.expand_path('..', __dir__)

# 1. Load and parse database configurations using absolute paths
db_config_path = File.join(APP_ROOT, "config", "database.yml")
db_configs = YAML.safe_load(ERB.new(File.read(db_config_path)).result, aliases: true)
current_env = ENV['DB_ENV'] || ENV['RACK_ENV'] || (ENV['VERCEL'] ? 'production' : 'development')
db_config = db_configs[current_env] || db_configs['production'] || db_configs['supabase'] || db_configs['development']

begin
  ActiveRecord::Base.establish_connection(db_config)
rescue StandardError => e
  warn "Database connection failed during boot: #{e.message}"
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:') if ENV['VERCEL']
end

class MicroserviceApp < Sinatra::Base
  set :method_override, true
  set :root, APP_ROOT
end

# require the controller(s)
Dir.glob(File.join(APP_ROOT, 'app', 'controllers', '*.rb')).each { |file| require file }
# require the model(s)
Dir.glob(File.join(APP_ROOT, 'app', 'models', '*.rb')).each { |file| require file }
#require serializers
Dir.glob(File.join(APP_ROOT, 'app', 'serializers', '*.rb')).each { |file| require file }
# configure Microservice settings