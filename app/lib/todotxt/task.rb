class Todotxt
  class Task
    include Comparable

    attr_accessor :priority
    attr_accessor :completion_date
    attr_accessor :creation_date

    delegate :<=>, to: :raw

    def to_s
      "<#{self.class}: \"#{raw}\">"
    end
    alias inspect to_s

    def raw
      [
        complete? && "x",
        priority && "(#{priority})",
        completion_date,
        creation_date,
        *parsed_description
      ].select { |x| x }.join(" ")
    end

    def dirty?
      raw != original_raw
    end

    def reset
      parse_and_initialize(original_raw)
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
        [tag.key, tag.value]
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
        Task.new(new_description).send(:parsed_description)
    end

    def contexts=(new_contexts)
      contexts_to_include = new_contexts.map { |c| Context.new(c) }
      parsed_description.map! { |part|
        if !part.is_a?(Context)
          part
        elsif contexts_to_include.include?(part)
          Utils.delete_first(contexts_to_include, part)
          part
        end
      }.compact!

      contexts_to_include.each do |context|
        parsed_description << context
      end
    end

    def projects=(new_projects)
      projects_to_include = new_projects.map { |c| Project.new(c) }
      parsed_description.map! { |part|
        if !part.is_a?(Project)
          part
        elsif projects_to_include.include?(part)
          Utils.delete_first(projects_to_include, part)
          part
        end
      }.compact!

      projects_to_include.each do |project|
        parsed_description << project
      end
    end

    def tags=(new_tags)
      tags_to_include = new_tags.map { |k, v| Tag.new(key: k, value: v) }
      parsed_description.map! { |part|
        if !part.is_a?(Tag)
          part
        elsif tags_to_include.map(&:key).include?(part.key)
          Utils.delete_first(tags_to_include) do |tag|
            tag.key == part.key
          end
        end
      }.compact!

      tags_to_include.each do |tag|
        parsed_description << tag
      end
    end

    private

    attr_reader :original_raw
    attr_reader :complete
    attr_accessor :parsed_description

    def parse_and_initialize(raw_task)
      raw_task = raw_task.strip
      parser_output = Parser.new.parse(raw_task)
      transform_output = Transform.new.apply(parser_output)
      initialize_task_data(original_raw: raw_task, **transform_output[:task])
    end
    alias initialize parse_and_initialize

    def initialize_task_data(
      original_raw:,
      description:,
      complete: false,
      priority: nil,
      completion_date: nil,
      creation_date: nil
    )
      @original_raw = original_raw
      @parsed_description = description
      @complete = !!complete
      @priority = priority&.to_s
      @completion_date = completion_date
      @creation_date = creation_date
    end

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
