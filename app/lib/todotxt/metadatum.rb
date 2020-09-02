class Todotxt
  class Metadatum < DescriptionPart
    attr_reader :key

    def initialize(key:, value:)
      super(value)
      @key = key.to_sym
    end

    def ==(other_metadatum)
      super && other_metadatum.key == key
    end

    def to_s
      "#{key}:#{value}"
    end
  end
end
