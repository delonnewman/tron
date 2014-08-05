require_relative 'helper'
require_relative '../lib/tron/middleware/app'
require_relative '../lib/tron/middleware/helpers'

class TestApp < Sinatra::Base
  configure do
    use Tron::Middleware
  end

  helpers do
    include Tron::WardenHelpers
  end

  get '/' do
    'This is the front door'
  end

  get '/admin' do
    authenticate!
    "Hey there! #{current_user}!"
  end
end

Capybara.app = TestApp

describe 'tron middleware interface', type: :feature do
  before do
    Tron::User.create(name: 'Tester', email: 'tester@example.com', activated: true)
    Tron::User.create(name: 'Tester', email: 'not-activated@example.com', activated: false)
  end

  it 'should provide a login screen' do
    visit '/login'
    expect(page).to have_content 'Login'
  end

  it 'should authenticate an activated user with valid vista credentials' do
    visit '/admin'
    expect(page).to have_content 'Login'
    within('form') do
      fill_in 'email', with: 'tester@example.com'
      fill_in 'access', with: CONFIG[:access]
      fill_in 'verify', with: CONFIG[:verify]
    end
    click_button 'Log in'
    expect(page).to have_content 'Hey there! Tester!'
  end

  it 'should reject an unactivated user with valid vista credentials' do
    visit '/admin'
    expect(page).to have_content 'Login'
    within('form') do
      fill_in 'email', with: 'not-activated@example.com'
      fill_in 'access', with: CONFIG[:access]
      fill_in 'verify', with: CONFIG[:verify]
    end
    click_button 'Log in'
    expect(page).to have_content 'This is the front door'
  end

  it 'should reject an unactivated user with invalid vista credentials' do
    visit '/admin'
    expect(page).to have_content 'Login'
    within('form') do
      fill_in 'email', with: 'not-activated@example.com'
      fill_in 'access', with: 'invalid-adfasdfadsfasdwqer2'
      fill_in 'verify', with: 'invalid-a24132dfewafdsd'
    end
    click_button 'Log in'
    expect(page).to have_content 'This is the front door'
  end

  it 'should reject an activated user with invalid vista credentials' do
    visit '/admin'
    expect(page).to have_content 'Login'
    within('form') do
      fill_in 'email', with: 'tester@example.com'
      fill_in 'access', with: 'invalid-adfasdfadsfasdwqer2'
      fill_in 'verify', with: 'invalid-a24132dfewafdsd'
    end
    click_button 'Log in'
    expect(page).to have_content 'This is the front door'
  end

  it 'should reject an missing user with valid vista credentials' do
    visit '/admin'
    expect(page).to have_content 'Login'
    within('form') do
      fill_in 'email', with: 'missing@example.com'
      fill_in 'access', with: CONFIG[:access]
      fill_in 'verify', with: CONFIG[:verify]
    end
    click_button 'Log in'
    expect(page).to have_content 'This is the front door'
  end
end
