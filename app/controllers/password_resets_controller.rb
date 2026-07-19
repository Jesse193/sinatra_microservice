require 'sinatra'
require 'json'
require_relative '../services/password_reset_mailer'

class PasswordResetsController < ApiBase
  configure do
    set :logging, true
  end

  GENERIC_REQUEST_MESSAGE = "If an account with that email exists, we've sent password reset instructions.".freeze

  post '/password_resets' do
    request.env['CACHED_RAW_BODY']
    payload = body.empty? ? {} : JSON.parse(body)

    email = payload['email'].to_s.strip.downcase

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

  rescue JSON::ParserError
    status 422
    { errors: ["Invalid JSON"] }.to_json

  rescue => e
    logger.error("Password reset request error: #{e.class} - #{e.message}")
    status 200
    { message: GENERIC_REQUEST_MESSAGE }.to_json
  end

  put '/password_resets/:token' do
    request.env['CACHED_RAW_BODY']
    payload = body.empty? ? {} : JSON.parse(body)

    user = User.find_by_reset_token(params[:token])

    if user.nil? || user.password_reset_token_expired?
      status 400
      halt({ error: "This password reset link is invalid or has expired." }.to_json)
    end

    user.password = payload['password']

    if payload.key?('password_confirmation')
      user.password_confirmation = payload['password_confirmation']
    end

    if user.save
      user.clear_password_reset_token!
      status 200
      { message: "Password successfully updated." }.to_json
    else
      status 422
      { errors: user.errors.full_messages }.to_json
    end

  rescue JSON::ParserError
    status 422
    { errors: ["Invalid JSON"] }.to_json
  end
end