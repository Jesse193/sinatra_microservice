require "bundler"
require 'dotenv'
Dotenv.load
Bundler.require

APP_ROOT = File.expand_path('..', __dir__)

db_config_path = File.join(APP_ROOT, "config", "database.yml")
db_configs = YAML.safe_load(ERB.new(File.read(db_config_path)).result, aliases: true)
current_env = ENV['DB_ENV'] || ENV['RACK_ENV'] || (ENV['VERCEL'] ? 'production' : 'development')
db_config = db_configs[current_env] || db_configs['production'] || db_configs['supabase'] || db_configs['development']

begin
  ActiveRecord::Base.establish_connection(db_config)
  ActiveRecord::Base.connection.verify!
rescue StandardError => e
  warn "FATAL: Database connection failed (env=#{current_env}): #{e.class}: #{e.message}"
  raise
end

class ApiBase < Sinatra::Base
  set :host_authorization, permitted_hosts: [
    'foodhaven.vercel.app',
    /.*\.vercel\.app$/,
    ENV['VERCEL_URL']
  ].compact
end

class MicroserviceApp < ApiBase
  set :method_override, true
  set :root, APP_ROOT
end

Dir.glob(File.join(APP_ROOT, 'app', 'controllers', '*.rb')).each { |file| require file }
Dir.glob(File.join(APP_ROOT, 'app', 'models', '*.rb')).each { |file| require file }
Dir.glob(File.join(APP_ROOT, 'app', 'serializers', '*.rb')).each { |file| require file }