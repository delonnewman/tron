require 'digest'

module Tron
  module Session
    def secret
      ENV['TRON_SECRET'] || raise('TRON_SECRET environment variable is not set')
    end

    def generate_secret
      Digest::SHA256.hexdigest(srand.to_s)
    end

    module_function :secret, :generate_secret
  end
end
