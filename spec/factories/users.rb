FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { "email@email.com" }
    password { "Pa55w0!rdis5ecureandlong" }
    password_confirmation { "Pa55w0!rdis5ecureandlong" }
  end
end