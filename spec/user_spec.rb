require_relative 'helper'

describe Tron::User do
  before :example, authentication: true do
    @user = create_activated_user
  end
  
  after do
    delete_all Tron::User
  end

  feature '#vista_authenticate?', authentication: true do
    it 'should authenticate with vista credentials' do
      expect(@user.vista_authenticate? site: '459', access: CONFIG[:access], verify: CONFIG[:verify]).to eq(true)
    end

    it 'will raise an exception if :site is missing' do
      expect { @user.vista_authenticate? email: 'somethingelse@example.com', access: 'aasdfasd', verify: 'adfsasdfasd' }.to raise_exception
    end
  
    it 'will raise an exception if :access is missing' do
      expect { @user.vista_authenticate? email: 'somethingelse@example.com', site: '459', verify: 'adfsasdfasd' }.to raise_exception
    end
  
    it 'will raise an exception if :verify is missing' do
      expect { @vista.vista_authenticate? email: 'somethingelse@example.com', site: '459', access: 'aasdfasd' }.to raise_exception
    end
  end

  feature '#authenticate?', authentication: true do
    it 'should authenticate with vista credentials' do
      expect(@user.authenticate? site: '459', access: CONFIG[:access], verify: CONFIG[:verify]).to eq(true)
    end
  end

  feature '.authenticate?', authentication: true do
    it 'should authenticate with email & vista credentials' do
      expect(Tron::User.authenticate? email: 'tester@example.com', site: '459', access: CONFIG[:access], verify: CONFIG[:verify]).to eq(true)
    end
  
    it 'should not authenticate with an invalid email' do
      expect(Tron::User.authenticate? email: 'somethingelse@example.com', site: '459', access: 'aasdfasd', verify: 'adfsasdfasd').to eq(false)
    end
  
    it 'should not authenticate with invalid vista credentials' do
      expect(Tron::User.authenticate? email: 'tester@example.com', site: '459', access: 'invalid-asdfasd', verify: 'invalid-adfasd').to eq(false)
    end

    it 'will raise an exception if :email is missing' do
      expect { Tron::User.authenticate? site: '459', access: 'aasdfasd', verify: 'adfsasdfasd' }.to raise_exception
    end
  end

  before :example, activation: true do
    @user = create_test_user activated: false
    @key  = @user.set_activation_key!
  end

  feature '#activate', activation: true do
    it 'should activate user with vista credentials' do
      @user.activate(CONFIG)
      expect(@user.activated?).to eq(true)
    end
  end

  feature '.activate', activation: true do
    it 'should activate user with vista credentials' do
      user = Tron::User.activate(CONFIG.merge email: @user.email, key: @key)
      expect(user.activated?).to eq(true)
    end
  end

  feature 'grant' do
    before do
      @user = create_test_user
      Tron::Application.create(name: :maestro, url: 'http://example.com/maestro')
      dragnet = Tron::Application.create(name: :dragnet, url: 'http://example.com/dragnet')
      Tron::Permission.create(name: :add_levels, description: 'User can add levels to Dragnet', application: dragnet)  
      Tron::Permission.create(name: :receive_email, description: 'User can receive email from any App')
    end

    after do
      delete_all Tron::UserPermission, Tron::Permission, Tron::Application, Tron::User
    end

    it 'can grant user permissions' do
      @user.grant(:add_levels, for: :dragnet)
      expect(@user.can? :add_levels, for: :dragnet).to eq(true)
      expect(@user.can? :add_levels).to eq(true)
    end
  
    it 'cannot grant user permissions for a different application than the permission specifies, if it specifies' do
      expect { @user.grant(:receive_email, for: :dragnet) }.not_to raise_exception
      expect { @user.grant(:add_levels, for: :maestro) }.to raise_exception
    end

    it 'cannot grant user the same permission more than once' do
      expect { @user.grant(:receive_email, for: :dragnet) }.not_to raise_exception
      expect { @user.grant(:receive_email, for: :dragnet) }.to raise_exception
    end
  end
end
