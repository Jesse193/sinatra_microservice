require 'spec_helper'

RSpec.describe 'Markets' do
  before(:each) do
    create_list(:market, 10)
    @market = Market.last
  end

  describe 'find a single market' do
    it 'hits the endpoint' do 
      get "api/markets/#{@market.id}"
      
      expect(last_response).to be_successful
    end
    
    it 'returns json object for the correct market' do 
      get "api/markets/#{@market.id}"

      market = JSON.parse(last_response.body, symbolize_names: true)[:data]
      
      expect(market[:attributes]).to have_key(:name)
      expect(market[:attributes][:name]).to eq(@market.name)
      
      expect(market[:attributes]).to have_key(:address)
      expect(market[:attributes][:address]).to eq(@market.address)

      expect(market[:attributes]).to have_key(:site)
      expect(market[:attributes][:site]).to eq(@market.site)

      expect(market[:attributes]).to have_key(:description)
      expect(market[:attributes][:description]).to eq(@market.description)

      expect(market[:attributes]).to have_key(:fnap)
      expect(market[:attributes][:fnap]).to eq(@market.fnap)

      expect(market[:attributes]).to have_key(:snap_option)
      expect(market[:attributes][:snap_option]).to eq(@market.snap_option)

      expect(market[:attributes]).to have_key(:accepted_payment)
      expect(market[:attributes][:accepted_payment]).to eq(@market.accepted_payment)

      expect(market[:attributes]).to have_key(:longitude)
      expect(market[:attributes][:longitude]).to eq(@market.longitude)

      expect(market[:attributes]).to have_key(:latitude)
      expect(market[:attributes][:latitude]).to eq(@market.latitude)
    end
  end
end
