class DailyScheduler
  def self.progress(todo_repo:)
    cleared_tasks = 0
    todo_repo.incomplete_tasks
      .select(&:today?)
      .map do |task|
      task.unschedule(update_scheduled_tag: true)
      cleared_tasks += 1
    end

    todo_repo.commit_todo_file("Automatically clear today list") && todo_repo.push

    RakeLogger.info "#{cleared_tasks} tasks cleared"
  end
end
