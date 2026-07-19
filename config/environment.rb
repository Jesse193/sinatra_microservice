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
  configure :production do
    set :host_authorization, permitted_hosts: [
      'sinatra-api.vercel.app',
      /.*\.vercel\.app$/,
      ENV['VERCEL_URL']
    ].compact
  end
  
  before do
    content_type :json

    allowed_origins = (
      ENV['ALLOWED_ORIGINS'] ||
      ENV['FRONTEND_ORIGIN'] ||
      'http://localhost:5173'
    ).split(',')
     .map { |o| o.strip.chomp('/') }
     .reject(&:empty?)

    origin = request.env['HTTP_ORIGIN'].to_s.chomp('/')

    if allowed_origins.include?(origin)
      response['Access-Control-Allow-Origin'] = origin
      response['Access-Control-Allow-Credentials'] = 'true'
    end

    response['Access-Control-Allow-Methods'] =
      'GET, POST, PUT, PATCH, DELETE, OPTIONS'

    response['Access-Control-Allow-Headers'] =
      'Content-Type, Authorization, Accept, X-Requested-With'

    @payload = {}

    if %w[POST PUT PATCH DELETE].include?(request.request_method)
      request.body.rewind
      body = request.body.read
      @payload = body.empty? ? {} : JSON.parse(body)
      request.body.rewind
    end
  rescue JSON::ParserError
    @payload = {}
  end

  options '*' do
    status 200
  end
end

class MicroserviceApp < ApiBase
  set :method_override, true
  set :root, APP_ROOT
end

Dir.glob(File.join(APP_ROOT, 'app', 'controllers', '*.rb')).each { |file| require file }
Dir.glob(File.join(APP_ROOT, 'app', 'models', '*.rb')).each { |file| require file }
Dir.glob(File.join(APP_ROOT, 'app', 'serializers', '*.rb')).each { |file| require file }