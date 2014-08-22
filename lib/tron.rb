require 'yaml'
require 'sequel'

require_relative 'tron/utils'

module Tron
  puts "Loading Tron in #{env} environment."

  DB = load_config! :database do |config|
         Sequel.connect(config)
       end

  puts '==> database configuration loaded successfully.'
end

require_relative 'tron/model'
puts '==> models loaded successfully.'
