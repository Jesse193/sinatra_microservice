require 'securerandom'
require 'digest'

class User < ActiveRecord::Base
  has_secure_password

  RESET_TOKEN_EXPIRY = 1.hour

  before_validation { email&.downcase!&.strip! }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password,
  presence: true,
  length: { minimum: 8 },
  format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])/,
    message: "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  },
  if: -> { password.present? }

  has_many :user_favorites, dependent: :destroy
  has_many :favorite_markets, through: :user_favorites, source: :market

  def generate_password_reset_token!
    raw_token = SecureRandom.urlsafe_base64(32)
    update!(
      reset_password_token_digest: self.class.digest_token(raw_token),
      reset_password_sent_at: Time.current
    )
    raw_token
  end

  def password_reset_token_expired?
    reset_password_sent_at.nil? || reset_password_sent_at < RESET_TOKEN_EXPIRY.ago
  end

  def clear_password_reset_token!
    update!(reset_password_token_digest: nil, reset_password_sent_at: nil)
  end

  def self.digest_token(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end

  def self.find_by_reset_token(raw_token)
    return nil if raw_token.to_s.strip.empty?
    find_by(reset_password_token_digest: digest_token(raw_token))
  end
end