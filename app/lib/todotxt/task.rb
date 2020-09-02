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

    def metadata
      description_parts_of_type(Metadatum).map { |d|
        [d.key, d.value]
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

    def raw=(new_raw_task)
      parse_and_initialize(new_raw_task)
    end

    def description=(new_description)
      self.parsed_description =
        Task.new(new_description).send(:parsed_description)
    end

    def contexts=(new_contexts)
      assign_tags(new_tags: new_contexts, tag_class: Context)
    end

    def projects=(new_projects)
      assign_tags(new_tags: new_projects, tag_class: Project)
    end

    def metadata=(new_metadata)
      assign_tags(
        new_tags: new_metadata,
        tag_class: Metadatum,
        tag_is_present: proc do |metadata, metadatum|
          metadata.map(&:key).include?(metadatum.key)
        end,
        delete_tag: proc do |metadata, metadatum|
          Utils.delete_first(metadata) { |d| d.key == metadatum.key }
        end
      )
    end

    private

    attr_reader :original_raw
    attr_reader :complete
    attr_accessor :parsed_description

    def parse_and_initialize(raw_task = "")
      raw_task ||= ""
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

    def assign_tags(
      new_tags:,
      tag_class:,
      tag_is_present: proc { |tags, tag| tags.include?(tag) },
      delete_tag: proc { |tags, tag| Utils.delete_first(tags, tag) }
    )
      tags_to_include = new_tags.map { |tag_args| tag_class.new(*tag_args) }

      parsed_description.map! { |part|
        if !part.is_a?(tag_class)
          # Leave other types of tags unchanged.
          part
        elsif tag_is_present.call(tags_to_include, part)
          # Replace existing tag with new version (always identical to old
          # version apart from in metadata case).
          delete_tag.call(tags_to_include, part)
        end
        # Implicit else: delete existing tags not present in `new_tags`.
      }.compact!

      # Add any new tags.
      tags_to_include.each do |tag|
        parsed_description << tag
      end
    end
  end
end
