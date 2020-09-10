class Todotxt
  class Parser < Parslet::Parser
    def initialize(parse_code_blocks: false)
      @parse_code_blocks = parse_code_blocks
    end

    root :task

    rule(:task) do
      (complete_task | incomplete_task).as(:task)
    end

    rule(:complete_task) do
      complete_marker >>
        priority_marker? >>
        completion_and_creation_dates? >>
        description
    end

    rule(:incomplete_task) do
      (
        priority_marker? >>
        creation_date? >>
        description
      )
    end

    rule(:complete_marker) { complete >> spaces }
    rule(:priority_marker?) { (priority >> spaces).maybe }
    rule(:creation_date?) do
      (date.as(:creation_date) >> spaces).maybe
    end
    rule(:completion_and_creation_dates?) do
      (
        date.as(:completion_date) >>
        spaces >>
        creation_date?
      ).maybe
    end

    rule(:complete) { str("x").as(:complete) }
    rule(:priority) do
      str("(") >> match("[A-Z]").as(:priority) >> str(")")
    end

    rule(:date) do
      match("[0-9]").repeat(4, 4).as(:year) >>
        str("-") >>
        match("[0-9]").repeat(2, 2).as(:month) >>
        str("-") >>
        match("[0-9]").repeat(2, 2).as(:day)
    end

    rule(:description) do
      part = description_part
      part = code_block | unmatched_backtick | part if parse_code_blocks
      part.repeat.as(:description)
    end
    rule(:description_part) do
      (project | context | metadatum | word) >> spaces?
    end

    rule(:code_block) do
      unless parse_code_blocks
        raise Todotxt::InternalError,
          "Invalid to call `code_block` when `parse_code_blocks` option not set"
      end

      (
        spaces? >>
        backtick >>
        spaces? >>
        (word >> spaces?).repeat >>
        spaces? >>
        backtick >>
        spaces?
      ).as(:code_block)
    end
    rule(:unmatched_backtick) do
      spaces? >> backtick.as(:word) >> spaces?
    end
    rule(:backtick) { str("`") }

    rule(:project) { tag(:project, "+") }
    rule(:context) { tag(:context, "@") }
    rule(:word) { identifier.as(:word) }

    rule(:identifier) { match_identifier }

    rule(:metadatum) do
      (
        metadatum_identifier.as(:key) >>
        str(":") >>
        (date | metadatum_identifier).as(:value)
      ).as(:metadatum)
    end
    rule(:metadatum_identifier) do
      match_identifier(except_chars: ":")
    end

    rule(:spaces?) { spaces.maybe }
    rule(:spaces) { space.repeat(1) }
    rule(:space) { match("\s") }

    private

    attr_reader :parse_code_blocks

    def tag(type, symbol)
      (str(symbol) >> identifier).as(type)
    end

    def match_identifier(except_chars: "")
      except_chars += "`" if parse_code_blocks
      match("[^\s#{except_chars}]").repeat(1)
    end
  end
end
