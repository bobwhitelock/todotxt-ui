class Todotxt
  class Tag < DescriptionPart
    attr_reader :key

    def initialize(key:, value:)
      super(value)
      @key = key.to_sym
    end

    def ==(other_tag)
      super && other_tag.key == key
    end

    def to_s
      "#{key}:#{value}"
    end
  end
end
