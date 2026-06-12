class MarketSerializer
  include JSONAPI::Serializer
  attributes :name, :email, :password_digest
end