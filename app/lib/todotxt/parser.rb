class Todotxt
  class Parser < Parslet::Parser
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
      description_part.repeat(1).as(:description)
    end
    rule(:description_part) do
      (project | context | key_value_tag | word) >> spaces?
    end
    rule(:word) { identifier.as(:word) }

    rule(:project) { tag(:project, "+") }
    rule(:context) { tag(:context, "@") }
    rule(:identifier) { match("[^\s]").repeat(1) }

    rule(:key_value_tag) do
      (
        key_value_tag_identifier.as(:key) >>
        str(":") >>
        key_value_tag_identifier.as(:value)
      ).as(:tag)
    end
    rule(:key_value_tag_identifier) { match("[^\s:]").repeat(1) }

    rule(:spaces?) { spaces.maybe }
    rule(:spaces) { space.repeat(1) }
    rule(:space) { match("\s") }

    private

    def tag(type, symbol)
      (str(symbol) >> identifier).as(type)
    end
  end
end
