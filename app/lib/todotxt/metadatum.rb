class Todotxt
  class Metadatum < DescriptionPart
    attr_reader :key

    def initialize(key, value)
      @key = key.to_sym
      @value = convert_value(value)
    end

    def ==(other_metadatum)
      super && other_metadatum.key == key
    end

    def to_s
      "#{key}:#{value}"
    end

    private

    def convert_value(value)
      value = value.to_s unless value.is_a?(Date)
      value_as_int = Integer(value, exception: false)
      value_as_int || value
    end
  end
end
