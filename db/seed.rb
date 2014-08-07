require_relative '../lib/tron'

def activate_admin(user)
  Tron.load_config! :admin do |h|
    user.set_activation_key!
    user.activate(h)
  end
end

def seed_db
  app = Tron::Application.create(name: 'tron', url: 'https://10.170.100.132/tron')
  Tron::Permission.create(name: :list_users, description: 'User can see a list of users', application: app)
  Tron::Permission.create(name: :add_users, description: 'User add users', application: app)
  Tron::Permission.create(name: :view_user, description: 'User can view any particular user', application: app)
  Tron::Permission.create(name: :update_user, description: 'User can update any particular user', application: app)
  Tron::Permission.create(name: :delete_user, description: 'User can delete any particular user', application: app)
  Tron::Permission.create(name: :list_user_permissions, description: 'User can see a list of a users permissions', application: app)
  Tron::Permission.create(name: :add_user_permissions, description: 'User can grant permissions to a user', application: app)
  Tron::Permission.create(name: :delete_user_permissions, description: 'User can remove permissions from a user', application: app)
  
  user = Tron::User.create(name: 'tron.admin', email: 'delon.newman@va.gov', activated: true)
  user.grant(:list_users, for: :tron)
  user.grant(:add_users, for: :tron)
  user.grant(:view_user, for: :tron)
  user.grant(:update_user, for: :tron)
  user.grant(:delete_user, for: :tron)
  user.grant(:list_user_permissions, for: :tron)
  user.grant(:add_user_permissions, for: :tron)
  user.grant(:delete_user_permissions, for: :tron)
  activate_admin user
end

if $0 == __FILE__
  puts '==> Seeding Database...'
  seed_db
  puts 'DONE.'
end
