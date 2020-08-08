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

    attr_reader :file

    def initialize(tasks = [], file: nil)
      @tasks = tasks.map { |task| to_task(task) }.compact
      @file = file
    end

    def to_a
      tasks.dup
    end

    private

    attr_reader :tasks

    def to_task(input_task)
      return input_task if input_task.is_a?(Task)
      input_task = input_task.strip
      return nil if input_task.empty?
      Task.parse(input_task)
    end
  end
end
