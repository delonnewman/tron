require 'bundler'
Bundler.require
require './lib/tron/session'
ENV['TRON_SECRET'] = Tron::Session.generate_secret
require './lib/tron/admin/app'
run Tron::Admin::App
