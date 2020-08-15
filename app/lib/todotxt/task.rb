class Todotxt
  class Task
    include Comparable

    def self.parse(raw_task)
      raw_task = raw_task.strip
      parser_output = Parser.new.parse(raw_task)
      transform_output = Transform.new.apply(parser_output)

      new(**transform_output[:task])
    end

    private_class_method :new

    attr_accessor :priority
    attr_accessor :completion_date
    attr_accessor :creation_date

    delegate :<=>, to: :raw

    def initialize(
      description:,
      complete: false,
      priority: nil,
      completion_date: nil,
      creation_date: nil
    )
      @parsed_description = description
      @complete = !!complete
      @priority = priority&.to_s
      @completion_date = completion_date
      @creation_date = creation_date
    end

    def raw
      [
        complete? && "x",
        priority && "(#{priority})",
        completion_date,
        creation_date,
        *parsed_description
      ].select { |x| x }.join(" ")
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
      description_parts_of_type(Context).map(&:to_s)
    end

    def projects
      description_parts_of_type(Project).map(&:to_s)
    end

    def tags
      description_parts_of_type(Tag).map { |tag|
        [tag.key.to_sym, tag.value]
      }.to_h
    end

    def complete=(value)
      return if complete == value
      @complete = value
      self.completion_date = if complete?
        Date.today
      end
    end

    def complete!
      self.complete = true
    end

    def increase_priority
      decrement_priority_char(1)
    end

    def decrease_priority
      decrement_priority_char(-1)
    end

    def description=(new_description)
      self.parsed_description =
        Task.parse(new_description).send(:parsed_description)
    end

    private

    attr_reader :complete
    attr_accessor :parsed_description

    def join_parts(parts)
      parts.map(&:to_s).join(" ")
    end

    def description_parts_of_type(type)
      parsed_description.select { |part| part.is_a?(type) }
    end

    def decrement_priority_char(delta)
      return unless priority
      new_priority = (priority.ord - delta).chr
      return unless ("A".."Z").cover?(new_priority)
      self.priority = new_priority
    end
  end
end
