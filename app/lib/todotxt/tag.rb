class Todotxt
  class Tag
    attr_reader :key
    attr_reader :value

    def initialize(key:, value:)
      @key = key.to_sym
      @value = value.to_s
    end

    def ==(other_tag)
      other_tag.is_a?(Tag) && other_tag.key == key && other_tag.value == value
    end

    def to_s
      "#{key}:#{value}"
    end
  end
end
