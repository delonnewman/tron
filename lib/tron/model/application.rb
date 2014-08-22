module Tron
  class Application < Sequel::Model
    def self.named(name)
      find(name: name.to_s)
    end

    def to_s
      name
    end

    def to_sym
      name.to_sym
    end
  end
end
