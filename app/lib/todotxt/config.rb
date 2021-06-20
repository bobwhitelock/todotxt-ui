class Todotxt
  class Config
    attr_reader :parse_code_blocks
    attr_reader :task_class

    def initialize(parse_code_blocks: false, task_class: Task)
      @parse_code_blocks = parse_code_blocks
      @task_class = task_class
    end

    def to_s
      "<#{self.class}: parse_code_blocks=#{parse_code_blocks} task_class=#{task_class}>"
    end
    alias_method :inspect, :to_s

    def parse_task(raw_task = "")
      raw_task ||= ""
      raw_task = raw_task.strip

      parser_output = parser.parse(raw_task)
      transform_output = transform.apply(parser_output)

      parsed_task = transform_output[:task]
      parsed_task[:description] = merge_adjacent_text(parsed_task[:description])

      {original_raw: raw_task, **parsed_task}
    end

    def parser
      @parser ||= Parser.new(parse_code_blocks: parse_code_blocks)
    end

    private

    def transform
      @transform ||= Transform.new
    end

    def merge_adjacent_text(parts)
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
