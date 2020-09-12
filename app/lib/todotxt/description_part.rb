class Todotxt
  class DescriptionPart
    PARSER_NAME = nil

    attr_reader :value
    alias to_s value

    def initialize(value)
      value = value.to_s
      validate_value!(value)
      @value = value
    end

    def ==(other_part)
      other_part.class == self.class && other_part.value == value
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
  end
end
