module Tron
  DB = begin
         Sequel.connect(ENV['TRON_DB_CONFIG'] || raise("environment variable TRON_DB_CONFIG is not set"))
       rescue => e
         puts "Could not load DB: #{e.message}"
         exit 1
       end
end
