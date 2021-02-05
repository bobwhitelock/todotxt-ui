class RakeLogger
  class << self
    # Delegate to Rails logger, but with all lines logged prefixed with full Rake
    # task name for current task.
    def method_missing(log_level, log_line)
      task_name = Rake.application.top_level_tasks.first
      log_line = "#{task_name}: #{log_line}"
      if respond_to?(log_level)
        Rails.logger.send(log_level, log_line)
      else
        super
      end
    end

    def respond_to_missing?(symbol, include_all)
      Rails.logger.respond_to?(symbol)
    end
  end
end
