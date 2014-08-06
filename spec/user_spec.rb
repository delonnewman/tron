require_relative 'helper'

describe Tron::User do
  before do
    Tron::User.create(name: 'Tester', email: 'test@example.com', activated: true)
  end
  
  after do
    Tron::User.dataset.delete
  end

  it 'should authenticate with email & vista credentials' do
    expect(Tron::User.authenticate? email: 'somethingelse@example.com', site: '459', access: 'aasdfasd', verify: 'adfsasdfasd').to eq(false)
    expect(Tron::User.authenticate? email: 'test@example.com', site: '459', access: 'invalid-asdfasd', verify: 'invalid-adfasd').to eq(false)
    expect(Tron::User.authenticate? email: 'test@example.com', site: '459', access: CONFIG[:access], verify: CONFIG[:verify]).to eq(true)
  end

  it 'will raise an exception if either :site, :access, :verify, or :email are missing' do
    expect { Tron::User.authenticate? site: '459', access: 'aasdfasd', verify: 'adfsasdfasd' }.to raise_exception
    expect { Tron::User.authenticate? email: 'somethingelse@example.com', access: 'aasdfasd', verify: 'adfsasdfasd' }.to raise_exception
    expect { Tron::User.authenticate? email: 'somethingelse@example.com', site: '459', verify: 'adfsasdfasd' }.to raise_exception
    expect { Tron::User.authenticate? email: 'somethingelse@example.com', site: '459', access: 'aasdfasd' }.to raise_exception
  end

  feature 'grant' do
    before do
      Tron::Application.create(name: :maestro, url: 'http://example.com/maestro')
      dragnet = Tron::Application.create(name: :dragnet, url: 'http://example.com/dragnet')
      Tron::Permission.create(name: :add_levels, description: 'User can add levels to Dragnet', application: dragnet)  
      Tron::Permission.create(name: :receive_email, description: 'User can receive email from any App')
    end

    after do
      Tron::UserPermission.dataset.delete
      Tron::Permission.dataset.delete
      Tron::Application.dataset.delete
    end

    it 'can grant user permissions' do
      u = Tron::User.first
      u.grant(:add_levels, for: :dragnet)
      expect(u.can? :add_levels, for: :dragnet).to eq(true)
      expect(u.can? :add_levels).to eq(true)
    end
  
    it 'cannot grant user permissions for a different application than the permission specifies, if it specifies' do
      u = Tron::User.first
      expect { u.grant(:receive_email, for: :dragnet) }.not_to raise_exception
      expect { u.grant(:add_levels, for: :maestro) }.to raise_exception
    end

    it 'cannot grant user the same permission more than once' do
      u = Tron::User.first
      expect { u.grant(:receive_email, for: :dragnet) }.not_to raise_exception
      expect { u.grant(:receive_email, for: :dragnet) }.to raise_exception
    end
  end
end
