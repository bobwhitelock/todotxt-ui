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
        new(File.readlines(path), file: path)
      end
    end

    # Undefine `Kernel#select` on this class, which isn't useful, and so
    # `select` will be handled via `method_missing` instead.
    undef select

    attr_reader :file

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
      raise Todotxt::UsageError, "No file set for #{self}" unless save_file
      File.open(save_file, "w") do |f|
        f.write(as_string)
      end
    end

    def as_string
      map(&:raw).join("\n") + "\n"
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
  end
end
