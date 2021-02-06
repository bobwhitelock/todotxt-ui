class DailyScheduler
  def self.progress(todo_repo:)
    incomplete_tasks = todo_repo.incomplete_tasks

    today_tasks = incomplete_tasks.select(&:today?)
    today_tasks.map do |task|
      task.unschedule(update_scheduled_tag: true)
    end

    tomorrow_tasks = incomplete_tasks.select(&:tomorrow?)
    tomorrow_tasks.map do |task|
      task.contexts -= ["@tomorrow"]
      task.schedule
    end

    todo_repo.commit_todo_file("Progress scheduled tasks") && todo_repo.push

    RakeLogger.info "#{today_tasks.length} tasks unscheduled"
    RakeLogger.info "#{tomorrow_tasks.length} tasks scheduled for today"
  end
end
