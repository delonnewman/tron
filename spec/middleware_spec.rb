require_relative 'helper'
require_relative '../lib/sinatra/tron'

class TestApp < Sinatra::Base
  register Sinatra::Tron

  get '/' do
    'This is the front door. <a href="/admin">Enter</a>.'
  end

  get '/admin' do
    authenticate!
    "Hey there! #{current_user}!"
  end
end

Capybara.app = TestApp

describe 'tron middleware interface', type: :feature do
  before do
    create_activated_user
    create_test_user email: 'not-activated@example.com'
  end

  after do
    delete_all Tron::User
  end

  it 'should provide a login screen' do
    visit '/login'
    expect(page).to have_content 'Login'
  end

  it 'should authenticate an activated user with valid vista credentials' do
    visit '/'
    expect(page).to have_content 'This is the front door'
    click_link 'Enter'
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
    expect(page).to have_content Tron::Middleware::MESSAGES[:UNSUCCESSFUL_LOGIN]
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
    expect(page).to have_content Tron::Middleware::MESSAGES[:MISSING_USER]
  end
end
