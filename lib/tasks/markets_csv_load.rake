require 'csv'
require './app/models/market'

namespace :csv_load do 
  task markets: :environment do 
    CSV.foreach("./db/data/farmersmarkets.csv", headers: true) do |row|
      next if row['listing_name'].nil? || row['location_x'].nil? || row['location_y'].nil?

      Market.create!(
        name: row['listing_name'],
        address: row['location_address'],
        site: row['location_site'],
        description: row['listing_desc'],
        fnap: row['FNAP'],
        snap_option: row['SNAP_option'],
        accepted_payment: row['acceptedpayment'],
        longitude: row['location_x'],
        latitude: row['location_y']
      )
    end
  end
end