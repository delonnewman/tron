require 'yaml'
require 'bundler'
Bundler.require(:default, :development)
begin
  require_relative 'lib/tron'
rescue => e
  puts '==> INFO: There was an error loading the Tron API. Likely because you\'re unable to connect to your database or your database uninitialized.'
  puts '          If you\'d like to know more run `rake pry` from the command line and you should get a full stack trace.'
end

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
    sh "sequel -Etm db/migrations #{"-M #{args[:version]}" if args[:version]} #{Tron.db_url}"
  end

  desc 'dump schema to db/schema.rb'
  task :dump do
    sh "sequel -tS db/schema.rb #{Tron.db_url}"
  end

  desc 'drop all tables in the database'
  task :drop do
    Tron::DB.tables.each do |t|
      Tron::DB.drop_table t, cascade: true
    end
  end

  desc 'run db/seed.rb'
  task :seed do
    sh 'ruby db/seed.rb'
  end
end
