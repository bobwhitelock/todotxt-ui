class Todotxt
  class Text
    attr_reader :value
    alias to_s value

    def initialize(value)
      @value = value
    end

    def ==(other_text)
      other_text.is_a?(Text) && other_text.value == value
    end
  end
end
