require 'bundler'
Bundler.require(:default, :test)
require_relative '../lib/tron/session'
ENV['TRON_SECRET'] = Tron::Session.generate_secret
ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'capybara/rspec'
CONFIG = JSON.parse IO.read(File.join(File.dirname(__FILE__), 'spec-config.json')), symbolize_names:true

require_relative '../lib/tron'

def create_test_user(args={})
  defaults = { name: 'Tester', email: 'tester@example.com', activated: false }
  Tron::User.create(defaults.merge(args))
end

def create_activated_user(args={})
  user = create_test_user(args)
  key  = user.set_activation_key!
  user.activate(CONFIG)
end

def delete_all(*models)
  models.each { |m| m.dataset.delete }
end

def do_login(args={})
  params = CONFIG.merge(args)
  email  = params[:email]  || raise(':email is required') 
  access = params[:access] || raise(':access is required') 
  verify = params[:verify] || raise(':verify is required') 

  visit '/login'
  within 'form' do
    fill_in 'email',  with: email
    fill_in 'access', with: access
    fill_in 'verify', with: verify
  end
  click_button 'Log in'
end
