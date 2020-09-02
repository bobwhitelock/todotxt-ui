class Todotxt
  class Transform < Parslet::Transform
    rule(complete: "x") { {complete: true} }

    rule(year: simple(:year), month: simple(:month), day: simple(:day)) do
      Date.new(year.to_i, month.to_i, day.to_i)
    end

    rule(description: sequence(:parts)) do
      {description: Transform.merge_words_in_parts(parts)}
    end
    rule(word: simple(:word)) { Text.new(word) }

    rule(project: simple(:value)) { Project.new(value) }
    rule(context: simple(:value)) { Context.new(value) }

    rule(metadatum: {key: simple(:key), value: simple(:value)}) do
      Metadatum.new(key: key, value: value)
    end

    def self.merge_words_in_parts(parts)
      merged_parts = []

      parts.each do |part|
        last_part = merged_parts.last
        if last_part.is_a?(Text) && part.is_a?(Text)
          combined_text = Text.new([last_part.value, part.value].join(" "))
          merged_parts[-1] = combined_text
        else
          merged_parts << part
        end
      end

      merged_parts
    end
  end
end
