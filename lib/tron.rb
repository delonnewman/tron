require 'yaml'
require 'sequel'

module Tron
  class << self
    def env
      ENV['RACK_ENV'] || 'development'
    end
  
    def config(name)
      YAML.load_file File.join(File.dirname(__FILE__), '..', "config/#{name}.yml")
    end

    def load_config!(name, e=env, &blk)
      begin
        cfg = config(:database)[e]
        blk ? blk.call(cfg) : cfg
      rescue => e
        puts "Error: #{e.message}"
        exit 1
      end
    end
  end

  puts "Loading Tron in #{env} environment."

  DB = load_config! :database do |config|
         Sequel.connect(config)
       end

  SESSION_SECRET = load_config! :secret
end

require_relative 'tron/model'
require_relative 'tron/middleware/app'
