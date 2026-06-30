require 'spec_helper'

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      email: 'email@email.com',
      name: 'John Doe',
      password: 'Pa55w0!rdis5ecureandlong'
    }
  end

  describe 'model initialization' do
    it 'creates a user with valid attributes' do
      user = create(:user, valid_attributes)
      
      expect(user).to be_valid
      expect(user.email).to eq('email@email.com')
      expect(user.name).to eq('John Doe')
      expect(user.password_digest).to_not eq('Pa55w0!rdis5ecureandlong')
    end
  end

  describe 'password validation' do
    it 'accepts a strong password' do
      user = build(:user, valid_attributes)
      expect(user).to be_valid
    end

    it 'rejects a weak password' do
      user = build(:user, valid_attributes.merge(password: 'password'))
      
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include('must include at least one lowercase letter, one uppercase letter, one number, and one special character')
    end
  end
end
