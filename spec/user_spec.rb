require_relative 'helper'

describe Tron::User do
  before :each do
    Tron::User.create(name: 'Tester', email: 'test@example.com', activated: true)
  end

  it 'should authenticate with email & vista credentials' do
    expect(Tron::User.authenticate? email: 'somethingelse@example.com', access: 'aasdfasd', verify: 'adfsasdfasd').to eq(false)
    expect(Tron::User.authenticate? email: 'test@example.com', access: 'invalid-asdfasd', verify: 'invalid-adfasd').to eq(false)
    expect(Tron::User.authenticate? email: 'test@example.com', access: CONFIG[:access], verify: CONFIG[:verify]).to eq(true)
  end
end
