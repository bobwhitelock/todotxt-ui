class DailyScheduler
  def self.progress(todo_repo:)
    today_tasks = todo_repo.incomplete_tasks.select(&:today?)
    today_tasks.map do |task|
      task.unschedule(update_scheduled_tag: true)
    end

    todo_repo.commit_todo_file("Automatically clear today list") && todo_repo.push

    RakeLogger.info "#{today_tasks.length} tasks cleared"
  end
end
