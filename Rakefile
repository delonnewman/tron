require 'yaml'
require 'bundler'
Bundler.require(:default, :development)
require_relative 'lib/tron'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "tron"
  gem.summary = %Q{Rack based web application and middleware for user user management}
  gem.description = %Q{Rack based web application and middleware for user user management}
  gem.email = "drnewman@phrei.org"
  gem.homepage = "http://phrei.org"
  gem.authors = ["Delon Newman"]
end
Jeweler::RubygemsDotOrgTasks.new

def db_url
  Tron.load_config! :database do |h|
    "#{h['adapter']}://#{h['user']}:#{h['password']}@#{h['host']}/#{h['database']}"
  end
end

desc "Run spec in ./spec"
task :spec do
  Dir['spec/*spec*.rb'].each do |test|
    sh "rspec #{test}"
  end
end

desc "Setup for development"
task :setup do
  sh "bundle"
end

desc "Open console in application environment"
task :pry do
  sh "bundle exec pry -r ./lib/tron"
end

namespace :db do
  desc 'run migrations with sequel command'
  task :migrate, [ :version ] do |t, args|
    sh "sequel -Em db/migrations #{"-M #{args[:version]}" if args[:version]} #{db_url}"
  end

  desc 'dump schema to db/schema.rb'
  task :dump do
    sh "sequel -S db/schema.rb #{db_url}"
  end

  desc 'run db/seed.rb'
  task :seed do
    sh 'ruby db/seed.rb'
  end
end
