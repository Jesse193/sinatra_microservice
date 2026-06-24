require 'spec_helper'

RSpec.describe User, type: :model do
  describe 'model initialization' do
    it 'creates a user with valid attributes' do
      user = create(:user, email: 'email@email.com', name: 'John Doe', password: 'Pa55w0!rdis5ecureandlong')
      expect(user).to be_a(User)
      expect(user.email).to eq('email@email.com')
      expect(user.name).to eq('John Doe')
      expect(user.password_digest).to_not eq('Pa55w0!rdis5ecureandlong')
    end
  end
end
