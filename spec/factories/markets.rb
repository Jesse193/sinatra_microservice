addresses = [
  "501 Foster Street, Durham, North Carolina 27701", 
  "15500 County Road 6, Plymouth, Minnesota 55447", 
  "7350 Pine Creek Road, Colorado Springs, Colorado 80919", 
  "Main Street & Church Street, Granville, NY, USA", 
  "3939 Granger Road, Medina, OH, USA", 
  "2441 Foothill Blvd., Rock Springs, WY, 82901", 
  "50 Upper Alabama Street, Atlanta, GA, USA"
  ]

FactoryBot.define do 
  factory :market do 
    name { Faker::Name.first_name }
    address { addresses.sample }
    site { Faker::Address.community }
    description { Faker::TvShows::MichaelScott.quote }
    fnap {Faker::Dessert.flavor }
    snap_option { Faker::Food.dish }
    accepted_payment { Faker::Currency.name }
    latitude { -104.7890345 }
    longitude { 40.7698435 }
  end
end