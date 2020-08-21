class Todotxt
  class DescriptionPart
    attr_reader :value
    alias to_s value

    def initialize(value)
      @value = value.to_s
    end

    def ==(other_part)
      other_part.class == self.class && other_part.value == value
    end
  end
end
