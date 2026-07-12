require_relative '../config/environment'
require_relative 'app'

Handler = Proc.new do |req|
  request_hash = req || {}
  headers = request_hash['headers'] || {}
  body = request_hash['body'].to_s
  path = request_hash['path'].to_s
  path = '/' if path.empty?
  path = path.sub(%r{^/}, '/')

  env = {
    'REQUEST_METHOD' => request_hash['method'] || 'GET',
    'PATH_INFO' => path,
    'QUERY_STRING' => request_hash['query'].to_s,
    'SCRIPT_NAME' => '',
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => '80',
    'rack.input' => StringIO.new(body),
    'rack.errors' => $stderr,
    'HTTP_HOST' => headers['host'].to_s,
    'HTTP_ORIGIN' => headers['origin'].to_s,
    'HTTP_AUTHORIZATION' => headers['authorization'].to_s,
    'CONTENT_TYPE' => headers['content-type'].to_s,
    'CONTENT_LENGTH' => body.bytesize.to_s
  }

  status, headers_out, body_out = APP.call(env)

  {
    'statusCode' => status,
    'headers' => headers_out,
    'body' => body_out.each.to_a.join
  }
end
