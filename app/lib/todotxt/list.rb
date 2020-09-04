class Todotxt
  class List
    class << self
      def load(io_or_path)
        if io_or_path.respond_to?(:readlines)
          load_from_io(io_or_path)
        else
          load_from_path(io_or_path)
        end
      end

      def load_from_string(string)
        new(string.lines)
      end

      private

      def load_from_io(io)
        path = io.path if io.respond_to?(:path)
        new(io.readlines, file: path)
      end

      def load_from_path(path)
        new(file: path).reload
      end
    end

    # Undefine `Kernel#select` on this class, which isn't useful, and so
    # `select` will be handled via `method_missing` instead.
    undef select

    attr_accessor :file

    def initialize(tasks = [], file: nil)
      @tasks = to_tasks(tasks)
      @file = file
    end

    def to_a
      tasks.dup
    end

    def to_s
      parts = [
        "#{self.class}:",
        file ? "file=\"#{file}\"" : nil,
        "tasks=#{tasks.map(&:raw)}"
      ].compact
      "<#{parts.join(" ")}>"
    end
    alias inspect to_s

    def respond_to_missing?(method, include_all)
      tasks.respond_to?(method, include_all)
    end

    def method_missing(method, *args, &block)
      super unless respond_to?(method)
      result = tasks.public_send(method, *args, &block)
      result == tasks ? self.tasks = to_tasks(tasks) : result
    end

    def save(file_path = nil)
      save_file = file_path || file
      verify_file!(save_file)
      File.open(save_file, "w") do |f|
        f.write(as_string)
      end
    end

    def as_string
      raw_tasks.join("\n") + "\n"
    end

    def raw_tasks
      map(&:raw)
    end

    def reload
      verify_file!(file)
      self.tasks = to_tasks(File.readlines(file))
      self
    end

    def archive_to(archive_file_or_list)
      archive_list = to_list(archive_file_or_list)
      archive_list.concat(complete_tasks)
      archive_list.save

      self.tasks = incomplete_tasks
      save if file
    end

    def complete_tasks
      select(&:complete?)
    end

    def incomplete_tasks
      select(&:incomplete?)
    end

    def all_contexts
      unique_task_attribute(&:contexts)
    end

    def all_projects
      unique_task_attribute(&:projects)
    end

    def all_metadata_keys
      unique_task_attribute { |task| task.metadata.keys }
    end

    private

    attr_accessor :tasks

    def to_tasks(maybe_tasks)
      maybe_tasks.map { |task| to_task(task) }.compact
    end

    def to_task(maybe_task)
      return maybe_task if maybe_task.is_a?(Task)
      raw_task = maybe_task.strip
      return nil if raw_task.empty?
      Task.new(raw_task)
    end

    def verify_file!(file)
      raise Todotxt::UsageError, "No file set for #{self}" unless file
    end

    def to_list(maybe_list)
      return maybe_list if maybe_list.is_a?(List)
      self.class.load(maybe_list)
    end

    def unique_task_attribute(&block)
      flat_map(&block).uniq.sort
    end
  end
end
