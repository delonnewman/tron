module Tron
  class Application < Sequel::Model
    def to_s
      name
    end
  end
end
