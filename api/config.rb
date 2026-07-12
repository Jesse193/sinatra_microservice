require_relative '../config/environment'
require_relative 'app'

Handler = Proc.new do |req|
  env = {
    'REQUEST_METHOD' => req['method'],
    'PATH_INFO' => req['path'],
    'QUERY_STRING' => req['query'].to_s,
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => '80',
    'rack.input' => StringIO.new(req['body'].to_s),
    'rack.errors' => $stderr,
    'HTTP_HOST' => req['headers']['host'].to_s,
    'HTTP_ORIGIN' => req['headers']['origin'].to_s,
    'HTTP_AUTHORIZATION' => req['headers']['authorization'].to_s,
    'CONTENT_TYPE' => req['headers']['content-type'].to_s,
    'CONTENT_LENGTH' => req['body'].to_s.bytesize.to_s
  }

  status, headers, body = APP.call(env)

  {
    'statusCode' => status,
    'headers' => headers,
    'body' => body.each.to_a.join
  }
end
