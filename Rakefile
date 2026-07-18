require "bundler"
Bundler.require

require "sinatra/activerecord"
require "sinatra/activerecord/rake"

task :environment do
  require File.expand_path('config/environment', __dir__)
end

Dir.glob('lib/tasks/*.rake').each { |r| load r}