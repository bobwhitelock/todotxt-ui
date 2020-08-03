class Todotxt
  class Context
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def ==(other_context)
      other_context.is_a?(Context) && other_context.value == value
    end
  end
end
