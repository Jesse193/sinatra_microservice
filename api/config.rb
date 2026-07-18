require_relative '../config/environment'
require_relative 'app'

Handler = Proc.new do |request, response|
  body =
    if request.body.respond_to?(:read)
      request.body.rewind if request.body.respond_to?(:rewind)
      request.body.read
    else
      request.body.to_s
    end

  env = {
    'REQUEST_METHOD' => request.request_method,
    'PATH_INFO'       => request.path,
    'QUERY_STRING'    => request.query_string.to_s,
    'SCRIPT_NAME'     => '',
    'SERVER_NAME'     => 'localhost',
    'SERVER_PORT'     => '80',
    'rack.input'      => StringIO.new(body),
    'rack.errors'     => $stderr,
    'HTTP_HOST'          => request['host'].to_s,
    'HTTP_ORIGIN'        => request['origin'].to_s,
    'HTTP_AUTHORIZATION' => request['authorization'].to_s,
    'CONTENT_TYPE'       => request['content-type'].to_s,
    'CONTENT_LENGTH'     => request.body.to_s.bytesize.to_s
  }
  status, headers_out, body_out = APP.call(env)

  response.status = status
  headers_out.each { |k, v| response[k] = v }
  response.body = body_out.each.to_a.join
end