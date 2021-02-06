class DailyScheduler
  def self.progress(todo_repo:)
    incomplete_tasks = todo_repo.incomplete_tasks

    today_tasks = incomplete_tasks.select(&:today?)
    today_tasks.map do |task|
      task.unschedule(update_scheduled_tag: true)
    end

    current_day = Date.today.strftime("%A")
    current_day_context = Context.from(current_day) # E.g. "@tuesday"
    new_today_tasks = incomplete_tasks.select { |task|
      contexts = task.contexts
      contexts.include?(current_day_context) || contexts.include?(Context::TOMORROW)
    }
    new_today_tasks.map do |task|
      task.contexts -= [current_day_context, Context::TOMORROW]
      task.schedule
    end

    todo_repo.commit_todo_file("Progress scheduled tasks") && todo_repo.push

    unscheduled = today_tasks.length
    RakeLogger.info "#{unscheduled} #{"task".pluralize(unscheduled)} unscheduled"

    scheduled = new_today_tasks.length
    RakeLogger.info "#{scheduled} #{"task".pluralize(scheduled)} scheduled for today"
  end
end
