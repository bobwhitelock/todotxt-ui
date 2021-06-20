class Todotxt
  class Metadatum < DescriptionPart
    attr_reader :key

    def initialize(key, value)
      @key = key.to_sym
      @value = convert_value(value)
    end

    def ==(other)
      super && other.key == key
    end

    def to_s
      "#{key}:#{value}"
    end

    def to_h
      {hash_key => {
        key: key.to_s,
        value: self.class.serialize_value(value)
      }}
    end

    def self.serialize_value(value)
      value.respond_to?(:iso8601) ? value.iso8601 : value
    end

    private

    def convert_value(value)
      value = value.to_s unless value.is_a?(Date)
      value_as_int = Integer(value, exception: false)
      value_as_int || value
    end
  end
end
