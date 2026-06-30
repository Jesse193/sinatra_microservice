require 'net/http'
require 'uri'
require 'json'

class PasswordResetMailer
  RESEND_API_URL = 'https://api.resend.com/emails'.freeze

  def self.send_reset_email(user, raw_token)
    api_key = ENV.fetch('RESEND_API_KEY')
    from = ENV.fetch('MAIL_FROM')
    frontend_url = ENV.fetch('FRONTEND_URL')

    reset_link = "#{frontend_url}/reset-password?token=#{raw_token}"

    body = {
      from: from,
      to: [user.email],
      subject: 'Reset your password',
      html: html_body(reset_link),
      text: text_body(reset_link)
    }

    uri = URI.parse(RESEND_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      warn "PasswordResetMailer: Resend API error (#{response.code}): #{response.body}"
    end

    response
  rescue => e
    warn "PasswordResetMailer: failed to send reset email - #{e.class}: #{e.message}"
    nil
  end

  def self.html_body(reset_link)
    <<~HTML
      <p>We received a request to reset your password.</p>
      <p><a href="#{reset_link}">Click here to reset your password</a></p>
      <p>This link will expire in 1 hour. If you didn't request this, you can safely ignore this email.</p>
    HTML
  end

  def self.text_body(reset_link)
    <<~TEXT
      We received a request to reset your password.

      Reset your password here: #{reset_link}

      This link will expire in 1 hour. If you didn't request this, you can safely ignore this email.
    TEXT
  end
end