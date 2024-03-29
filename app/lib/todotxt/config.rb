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

      {original_raw: raw_task, **transform_output[:task]}
    end

    def parser
      @parser ||= Parser.new(parse_code_blocks: parse_code_blocks)
    end

    private

    def transform
      @transform ||= Transform.new
    end
  end
end
