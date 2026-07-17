require 'sinatra'
require 'json'
require_relative '../services/password_reset_mailer'

class PasswordResetsController < ApiBase
  configure do
    set :logging, true
  end

  before do
    content_type :json

    allowed_origins = (ENV['ALLOWED_ORIGINS'] || ENV['FRONTEND_ORIGIN'] || 'http://localhost:5173').split(',').map(&:strip).reject(&:empty?)
    origin = request.env['HTTP_ORIGIN'].to_s
    if allowed_origins.include?(origin)
      response.headers['Access-Control-Allow-Origin'] = origin
      response.headers['Access-Control-Allow-Credentials'] = 'true'
    end

    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization'

    @payload = {}
    if request.env['REQUEST_METHOD'] != 'GET' && request.body
      begin
        body_text = request.body.read
        @payload = JSON.parse(body_text) unless body_text.to_s.strip.empty?
      rescue JSON::ParserError
        @payload = {}
      ensure
        request.env['rack.input'] = StringIO.new(body_text || '')
      end
    end
  end

  options '*' do
    status 200
  end

  GENERIC_REQUEST_MESSAGE = "If an account with that email exists, we've sent password reset instructions.".freeze

  post '/password_resets' do
    email = @payload['email'].to_s.strip.downcase

    if email.empty?
      status 422
      halt({ errors: ["Email is required"] }.to_json)
    end

    user = User.find_by(email: email)

    if user
      raw_token = user.generate_password_reset_token!
      PasswordResetMailer.send_reset_email(user, raw_token)
    end

    status 200
    { message: GENERIC_REQUEST_MESSAGE }.to_json
  rescue => e
    logger.error("Password reset request error: #{e.class} - #{e.message}")
    status 200
    { message: GENERIC_REQUEST_MESSAGE }.to_json
  end

  put '/password_resets/:token' do
    user = User.find_by_reset_token(params[:token])

    if user.nil? || user.password_reset_token_expired?
      status 400
      halt({ error: "This password reset link is invalid or has expired." }.to_json)
    end

    new_password = @payload['password']

    user.password = new_password
    user.password_confirmation = @payload['password_confirmation'] if @payload.key?('password_confirmation')

    if user.save
      user.clear_password_reset_token!
      status 200
      { message: "Password successfully updated." }.to_json
    else
      status 422
      { errors: user.errors.full_messages }.to_json
    end
  end
end