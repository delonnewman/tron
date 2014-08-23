module Tron
  class << self
    def env
      ENV['RACK_ENV'] || 'development'
    end
  
    def db_url(e=env)
      load_config! :database, e do |h|
        "#{h['adapter']}://#{h['user']}:#{h['password']}@#{h['host']}/#{h['database']}"
      end
    end
    
    def config(name)
      file = File.join(File.dirname(__FILE__), '..', '..', "config/#{name}.yml")
      raise "#{file} does not exist" unless File.exists? file
      h = YAML.load_file file
      symbolize_keys h
    end

    def load_config!(name, e=env, &blk)
      cfg = config(name)[e]
      raise "there is no #{name} configuration for a #{e} environment" unless cfg
      blk ? blk.call(cfg) : cfg
    end

    def symbolize_keys(h)
      new = {}
      h.each_pair do |k, v|
        val = if v.respond_to? :each_pair
                symbolize_keys v
              else
                v
              end

        new[k.to_sym] = val
        new[k] = val
      end
      new
    end
  end
end
