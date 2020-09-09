require "todotxt/exceptions"

class Todotxt
  class << self
    attr_writer :config

    def config
      @config ||= Config.new
    end
  end
end
