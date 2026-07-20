require 'spec_helper'

RSpec.describe Market, type: :model do
  describe 'class methods' do 
    describe 'benefits' do 
      let!(:markets) { create_list(:market, 7) }

      it '::accepts_benefits' do 
        result = Market.accepts_benefits
        expect(result.count).to eq(7) 
      end

      it '::snap_available' do 
        result = Market.snap_available
        expect(result.count).to eq(7)
      end

      it '::fnap_available' do 
        result = Market.fnap_available
        expect(result.count).to eq(7)
      end
    end

    describe 'proximity' do 
      it '::nearby_markets' do 
        market_1 = create(:market, longitude: -81.1478018, latitude: 36.1582212)
        market_2 = create(:market, longitude: -81.2843197, latitude: 35.6741832)
        market_3 = create(:market, longitude: -117.90522, latitude: 48.543279)
        market_4 = create(:market, longitude: -80.3862664534582, latitude: 33.97372952277976)
        market_5 = create(:market, longitude: -73.686043, latitude: 40.983895)
        result = Market.nearby_markets({latitude: 34.60, longitude: -80.34, radius: 50})
        expect(result.to_a).to eq([market_4])
      end
    end
  end
end
