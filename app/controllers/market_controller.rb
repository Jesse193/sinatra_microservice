class MarketsController < Sinatra::Base
  set :default_content_type, 'application/json'
  get '/markets' do 
    markets = Market.all
    json MarketSerializer.new(markets)
  end

  get '/markets/search' do 
    markets = Market.nearby_markets(params)
    json MarketSerializer.new(markets)
  end
  
  get '/markets/:id' do 
    market = Market.find(params[:id])
    json MarketSerializer.new(market)
  end
end