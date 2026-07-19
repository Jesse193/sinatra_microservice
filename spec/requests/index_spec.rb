require './spec/spec_helper.rb'

RSpec.describe 'Market Index', type: :request do
  
  describe 'endpoint' do
    it 'returns all markets' do 
      create_list(:market, 5)
      get 'api/markets'
      expect(last_response).to be_successful

      markets = JSON.parse(last_response.body, symbolize_names: true)[:data]

      expect(markets.count).to eq(5)

      markets.each do |market|
        expect(market[:attributes]).to have_key(:name)
        expect(market[:attributes][:name]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:address)
        expect(market[:attributes][:address]).to be_a(String)

        expect(market[:attributes]).to have_key(:site)
        expect(market[:attributes][:site]).to be_a(String)

        expect(market[:attributes]).to have_key(:description)
        expect(market[:attributes][:description]).to be_a(String)

        expect(market[:attributes]).to have_key(:fnap)
        expect(market[:attributes][:fnap]).to be_a(String)

        expect(market[:attributes]).to have_key(:snap_option)
        expect(market[:attributes][:snap_option]).to be_a(String)

        expect(market[:attributes]).to have_key(:accepted_payment)
        expect(market[:attributes][:accepted_payment]).to be_a(String)

        expect(market[:attributes]).to have_key(:longitude)
        expect(market[:attributes][:longitude]).to be_an(Float)

        expect(market[:attributes]).to have_key(:latitude)
        expect(market[:attributes][:latitude]).to be_an(Float)
      end
    end
  end
end