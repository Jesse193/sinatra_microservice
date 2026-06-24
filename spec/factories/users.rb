FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { "email@email.com" }
    password_digest { "Pa55w0!rdis5ecureandlong" }
  end
end