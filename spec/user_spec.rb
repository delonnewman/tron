require_relative 'helper'

describe Tron::User do
  before do
    Tron::User.create(name: 'Tester', email: 'test@example.com', activated: true)
  end

  it 'should authenticate with email & vista credentials' do
    expect(Tron::User.authenticate? email: 'somethingelse@example.com', access: 'aasdfasd', verify: 'adfsasdfasd').to eq(false)
    expect(Tron::User.authenticate? email: 'test@example.com', access: 'invalid-asdfasd', verify: 'invalid-adfasd').to eq(false)
    expect(Tron::User.authenticate? email: 'test@example.com', access: CONFIG[:access], verify: CONFIG[:verify]).to eq(true)
  end

  it 'can grant user permissions' do
    app = Tron::Application.create(name: :dragnet, url: 'http://example.com/dragnet')
    Tron::Permission.create(name: :add_levels, description: 'User can add levels to Dragnet', application: app)  
    u = Tron::User.first
    u.grant(:add_levels, for: :dragnet)
    expect(u.can? :add_levels, for: :dragnet).to eq(true)
    expect(u.can? :add_levels).to eq(true)
  end
end
