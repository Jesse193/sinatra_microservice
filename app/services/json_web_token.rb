require 'jwt'

class JsonWebToken
  ALGORITHM = 'HS256'.freeze

  SECRET_KEY = ENV.fetch('JWT_SECRET') do
    raise 'JWT_SECRET environment variable is not set. Refusing to start with an insecure default secret.'
  end

  def self.encode(payload, exp = 24.hours.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(
      token,
      SECRET_KEY,
      true,
      {
        algorithm: ALGORITHM,
        verify_expiration: true 
      }
    )[0]

    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError
    nil
  end
end