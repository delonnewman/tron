ENV[RACK_ENV] = 'development' unless ENV['RACK_ENV']

require 'jeweler'
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
  
end

desc "Run tests in ./spec"
task :test do
  Dir['spec/*spec*.rb'].each do |test|
    sh "rspec #{test}"
  end
end

desc "Setup for development"
task :setup do
  sh "bundle"
end

namespace :db do
  desc 'run migrations with sequel command'
  task :migrate do
    sh "sequel -em db/migrations"
  end

  desc 'dump schema to db/schema.rb'
  task :dump do
    sh "sequel -S db/schema.rb"
  end
end
