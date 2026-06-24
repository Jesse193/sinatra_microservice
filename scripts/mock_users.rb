#!/usr/bin/env ruby

require 'bundler/setup'

app_root = File.expand_path('..', __dir__)

env_path = File.join(app_root, 'config', 'environment.rb')
app_path = File.join(app_root, 'app.rb')

if File.exist?(env_path)
  require env_path
elsif File.exist?(app_path)
  require app_path
else
  warn 'Unable to load application environment. Make sure config/environment.rb or app.rb exists.'
  exit 1
end

begin
  require_relative '../models/user'
rescue LoadError
end

MOCK_USERS = [
  { name: 'Alice Baker', email: 'alice@example.com', password: 'password1' },
  { name: 'Bob Carter', email: 'bob@example.com', password: 'password2' },
  { name: 'Carol Davis', email: 'carol@example.com', password: 'password3' },
  { name: 'Dan Edwards', email: 'dan@example.com', password: 'password4' },
  { name: 'Eve Fisher', email: 'eve@example.com', password: 'password5' }
].freeze

unless defined?(User)
  warn 'User model not defined. Please confirm your app environment loads the User model.'
  exit 1
end

MOCK_USERS.each do |attrs|
  user = User.find_by(email: attrs[:email]) || User.new
  user.assign_attributes(attrs)

  if user.save
    puts "Created/updated user: #{user.email}"
  else
    warn "Failed to save user #{attrs[:email]}: #{user.errors.full_messages.join(', ')}"
  end
end
