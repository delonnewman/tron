require 'bundler'
Bundler.require(:default, :test)
require_relative '../lib/tron/session'
ENV['TRON_SECRET'] = Tron::Session.generate_secret
ENV['RACK_ENV'] = 'test'
require_relative '../lib/tron'
require 'rspec'
require 'capybara/rspec'
CONFIG = JSON.parse IO.read(File.join(File.dirname(__FILE__), 'spec-config.json')), symbolize_names:true
