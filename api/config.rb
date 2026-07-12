require_relative '../config/environment'
require_relative 'app'

Handler = Proc.new do |req, res|
  status = 200
  headers = { 'Content-Type' => 'application/json' }
  body = { message: 'ok' }.to_json

  res.status = status
  headers.each { |k, v| res[k] = v }
  res.body = body
end
