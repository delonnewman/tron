$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'sinatra'
require 'tron'
require 'tron/session'
ENV['TRON_SECRET'] = Tron::Session.generate_secret
require 'sinatra/tron'

get '/' do
  'This is the front door. <a href="/admin">Enter</a>.'
end

get '/admin' do
  authenticate!
  'You\'re inside!'
end
