require 'spec_helper'

RSpec.describe 'User Login Endpoint', type: :request do
  it 'logs in a user with valid credentials' do
    user = create(:user, email: 'johndoe@example.com', name: 'John Doe', password: 'Password123!')

    payload = {
      email: 'johndoe@example.com',
      password: 'Password123!'
    }

    post '/api/login', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response).to be_successful
  end

end
