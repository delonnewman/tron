require_relative 'helper'
require_relative '../lib/tron/admin/app'
require_relative '../db/seed'

Capybara.app = Tron::Admin::App

describe 'tron admin interface', type: :feature do
  feature 'CRUD operations on users' do
    before do
      seed_db
    end

    after do
      delete_all Tron::UserPermission, Tron::Permission,Tron::Application, Tron::User
    end

    it 'can list users' do
      do_login email: CONFIG[:admin_email] # default admin user email
      visit '/users'
      expect(page).to have_selector '#users'
    end
    it 'can add users' do
    end
    it 'can view user' do
      
    end
    it 'can update user'
    it 'can delete user'
  end

  it 'should allow CRUD operations on permissions' 
  it 'should allow CRUD operations on user permissions'
  it 'should allow CRUD operations on applications'
  it 'should send invitation email to user to setup account permissions for a given application'

  feature :activation do
    before :example do
      @user = create_test_user activated: false
      @key  = @user.set_activation_key!
    end

    after :example do
      delete_all Tron::User
    end
  
    it 'should activate user when passing an activation key and user gives valid vista credentials' do
      visit "/activate?email=#{@user.email}&key=#{@key}"
      expect(page).to have_content 'Enter your VistA credentials to activate your account.'
      expect(page).to have_selector 'form'
      within 'form' do
        fill_in 'access', with: CONFIG[:access]
        fill_in 'verify', with: CONFIG[:verify]
        click_button 'Activate'
      end
      expect(page).to have_content 'Your account has been activated.'
    end

    it 'should fail to activate when passing an invalid activation key' do
      visit "/activate?email=#{@user.email}&key=invalidkey"
      expect(page).to have_content 'There was an error trying to activate your account'

      visit "/activate?email=#{@user.email}&key=adfadfwr42341fr213r21341rqw1235r11eqwrqwerqwerqewrq"
      expect(page).to have_content 'There was an error trying to activate your account'
    end
  end
end
