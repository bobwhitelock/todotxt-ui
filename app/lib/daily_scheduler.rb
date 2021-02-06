class DailyScheduler
  def self.progress(todo_repo:)
    incomplete_tasks = todo_repo.incomplete_tasks

    yesterday_tasks = incomplete_tasks.select { |task|
      task.contexts.include?(Context::YESTERDAY)
    }.map { |task|
      task.contexts -= [Context::YESTERDAY]
    }

    today_tasks = incomplete_tasks.select(&:today?).map { |task|
      task.unschedule(update_scheduled_tag: true)
      task.contexts += [Context::YESTERDAY]
    }

    current_day = Date.today.strftime("%A")
    current_day_context = Context.from(current_day) # E.g. "@tuesday"
    new_today_tasks = incomplete_tasks.select { |task|
      contexts = task.contexts
      contexts.include?(current_day_context) || contexts.include?(Context::TOMORROW)
    }.map { |task|
      task.contexts -= [current_day_context, Context::TOMORROW]
      task.schedule
    }

    todo_repo.commit_todo_file("Progress scheduled tasks") && todo_repo.push

    untagged_with_yesterday = yesterday_tasks.length
    RakeLogger.info "#{untagged_with_yesterday} #{"task".pluralize(untagged_with_yesterday)} untagged with @yesterday"

    unscheduled = today_tasks.length
    RakeLogger.info "#{unscheduled} #{"task".pluralize(unscheduled)} unscheduled"

    scheduled = new_today_tasks.length
    RakeLogger.info "#{scheduled} #{"task".pluralize(scheduled)} scheduled for today"
  end
end
