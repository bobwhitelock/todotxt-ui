class RakeLogger
  # Delegate to Rails logger, but with all lines logged prefixed with full Rake
  # task name for current task.
  def self.method_missing(log_level, log_line)
    task_name = Rake.application.top_level_tasks.first
    log_line = "#{task_name}: #{log_line}"
    Rails.logger.send(log_level, log_line)
  end
end
