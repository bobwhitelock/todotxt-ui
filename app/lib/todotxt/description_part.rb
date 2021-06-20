class Todotxt
  class DescriptionPart
    PARSER_NAME = nil

    attr_reader :value
    alias_method :to_s, :value

    def initialize(value)
      value = value.to_s
      validate_value!(value)
      @value = value
    end

    def ==(other)
      other.class == self.class && other.value == value
    end

    def to_h
      {hash_key => value}
    end

    private

    def validate_value!(value)
      part_parser&.parse(value)
    rescue Parslet::ParseFailed
      raise Todotxt::UsageError, "Not a valid #{parser_name}: `#{value}`"
    end

    def part_parser
      return unless parser_name
      Todotxt.config.parser.public_send(parser_name)
    end

    def parser_name
      self.class::PARSER_NAME
    end

    def hash_key
      self.class.to_s.downcase.split("::").last.to_sym
    end
  end
end
