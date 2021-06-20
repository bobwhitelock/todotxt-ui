class Todotxt
  class Transform < Parslet::Transform
    rule(complete: "x") { {complete: true} }

    rule(year: simple(:year), month: simple(:month), day: simple(:day)) do
      Date.new(year.to_i, month.to_i, day.to_i)
    end

    rule(code_block: sequence(:words)) do
      Text.new("`#{words.join(" ")}`")
    end
    rule(code_block: simple(:word)) { Text.new(word) }

    rule(word: simple(:word)) { Text.new(word) }

    rule(project: simple(:value)) { Project.new(value) }
    rule(context: simple(:value)) { Context.new(value) }

    rule(metadatum: {key: simple(:key), value: simple(:value)}) do
      Metadatum.new(key, value)
    end
  end
end
