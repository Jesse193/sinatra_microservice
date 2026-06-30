class MarketsController < Sinatra::Base
  set :default_content_type, 'application/json'
  get '/markets' do 
    markets = Market.all
    json MarketSerializer.new(markets)
  end

  get '/markets/search' do
    if params[:latitude] && params[:longitude]
      markets = Market.nearby_markets(params)
    elsif params[:addressLine1] || params[:city] || params[:state] || params[:zipCode]
      markets = Market.market_by_address(params)
    elsif params[:address]
      markets = Market.market_by_address(params)
    elsif params[:name]
      markets = Market.market_by_name(params)
    else
      halt 400, json({ error: 'No valid search parameters provided' })
    end

    json MarketSerializer.new(markets)
  end
  
  get '/markets/:id' do 
    market = Market.find(params[:id])
    json MarketSerializer.new(market)
  end
end