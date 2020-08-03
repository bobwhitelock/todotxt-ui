class Todotxt
  class Tag
    attr_reader :key
    attr_reader :value

    def initialize(key:, value:)
      @key = key
      @value = value
    end

    def ==(other_tag)
      other_tag.is_a?(Tag) && other_tag.key == key && other_tag.value == value
    end
  end
end
