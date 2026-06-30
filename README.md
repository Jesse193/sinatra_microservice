# FoodHaven
### This is a fork of the original project I worked on [FoodHaven] (https://github.com/FoodHaven/microservice_sinatra)

# Introduction
This API is a service built to store farmers market data downloaded from the USDA Local Food Portal farmers market directory [here](https://www.usdalocalfoodportal.com/fe/datasharing/) and expose endpoints to access specific subsets of that data.

# Features
* Exposes 6 endpoints that return various subsets of farmers market info as JSON
* Stores the farmers markets in a Postgresql database. 

# Set Up
Should it be necessary to install this application on your local machine, follow these steps: 
1. In your terminal, in the directory you intend to store this application, run 
 - ```git clone github.com/Jesse193/sinatra_microservice```
2. Enter the microservice-sinatra directory and run the following commands: 
 - ```bundle install```
 - ```rake db:{drop,create,migrate,seed}```
   ```rake db:prepare:test```
3. To run this application locally, run this from the command line: 
 - ```bundle exec rackup config.ru```

# API Endpoints
## Markets
GET `api/markets`
- Renders an index of all farmers markets in the database.

GET `api/markets/{:id}`
- Renders a JSON object for a single market by that market's id.

GET `api/markets/search?longitude={longitude}&latitude={latitude}&radius={radius}`
- Returns a list of markets within the radius of a specific latitude and longitude. Radius, latitude and longitude are passed as query parameters when making a request to this endpoint.

GET `api/markets/search?address_line{#market_id}={addressLine1}&city={city}&state={state}&zip_code={zipCode}`
- Returns a list of markets that closly match an address. Address line 1 (street address), city, state, and zip code are passed as query parameters when making a request to this endpoint.

GET `api/markets/search?name={name}`
- Returns a list of markets that closly match by its name. Name is passed as a query parameter when making a request to this endpoint.

GET `api/markets/favorites?market_ids[]={:id}&market_ids[]={:id}&market_ids[]={:id}`
- Renders a list of markets by their ids. Arrays of ids are passed as query parameters when making a request to this endpoint. 

## Users

POST `api/register`

params: {email: fake@fake.com,
password: fakePassword}

POST `api/login`

params: {email: fake@fake.com,
password: fakePassword}

POST `api/favorites`

Adds a market to user's favorite markets

params: {market_id: {#market_id}}

GET `api/favorites`

Gets user's favorite markets


DELETE `api/favorites/:id`

params: {market_id: {#market_id}}

Deletes market from user's favorite markets


## Authors
### I worked on this fork so that I could further refactor, add more features, and deploy

### This is a fork of the original project [FoodHaven] (https://github.com/FoodHaven/microservice_sinatra) Please see documentation to see everyone that worked on the original project.


# Sources: 
USDA’s Agricultural Marketing Service &amp; Michigan State University. (n.d.). USDA local food directories. USDA Local Food Directories. https://www.usdalocalfoodportal.com/fe/datasharing/ 