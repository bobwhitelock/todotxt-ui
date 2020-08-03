class Todotxt
  class Task
    def self.parse(raw_task)
      parser_output = Parser.new.parse(raw_task)
      transform_output = Transform.new.apply(parser_output)

      new(raw: raw_task, **transform_output[:task])
    end

    private_class_method :new

    attr_reader :raw
    attr_reader :priority
    attr_reader :completion_date
    attr_reader :creation_date

    def initialize(
      raw:,
      description:,
      complete: false,
      priority: nil,
      completion_date: nil,
      creation_date: nil
    )
      @raw = raw
      @parsed_description = description
      @complete = complete
      @priority = priority
      @completion_date = completion_date
      @creation_date = creation_date
    end

    def complete?
      complete
    end

    def description
      join_parts(parsed_description)
    end

    def description_text
      join_parts(description_parts_of_type(Text))
    end

    def contexts
      description_parts_of_type(Context)
    end

    def projects
      description_parts_of_type(Project)
    end

    def tags
      description_parts_of_type(Tag)
    end

    private

    attr_reader :complete
    attr_reader :parsed_description

    def join_parts(parts)
      parts.map(&:to_s).join(" ")
    end

    def description_parts_of_type(type)
      parsed_description.select { |part| part.is_a?(type) }
    end
  end
end
