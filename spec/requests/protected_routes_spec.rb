require 'spec_helper'

RSpec.describe 'Protected Endpoints Authentication', type: :request do
  let!(:user) { create(:user, email: 'guard@example.com', password: 'securepassword123') }
  
  let(:valid_token) { JsonWebToken.encode(user_id: user.id) }
  let(:invalid_token) { 'this-is-a-fake-untrusted-token-string' }

  describe 'GET /api/protected_data' do
    context 'when the request is authorized' do
      it 'returns status 200 and unlocks the data' do
        headers = { 
          'HTTP_AUTHORIZATION' => "Bearer #{valid_token}",
          'CONTENT_TYPE' => 'application/json'
        }

        get '/api/protected_data', {}, headers

        expect(last_response.status).to eq(200)
        
        response_body = JSON.parse(last_response.body)
        expect(response_body['secret_data']).to include('guard@example.com')
      end
    end

    context 'when the request lacks a token or uses an invalid token' do
      it 'returns a 401 Unauthorized status code' do
        headers = { 
          'HTTP_AUTHORIZATION' => "Bearer #{invalid_token}",
          'CONTENT_TYPE' => 'application/json'
        }

        get '/api/protected_data', {}, headers

        expect(last_response.status).to eq(401)
        
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Access Denied: Missing or invalid token')
      end
    end
  end
end
