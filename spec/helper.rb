ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'bundler'
Bundler.require(:default, :test)
