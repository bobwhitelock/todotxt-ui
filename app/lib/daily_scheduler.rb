class DailyScheduler
  def self.progress(todo_repo:)
    incomplete_tasks = todo_repo.incomplete_tasks

    yesterday_tasks = incomplete_tasks.select { |task|
      task.contexts.include?(Context::YESTERDAY)
    }.each do |task|
      task.contexts -= [Context::YESTERDAY]
    end

    today_tasks = incomplete_tasks.select(&:today?).each do |task|
      task.unschedule(update_scheduled_tag: true)
      task.contexts += [Context::YESTERDAY]
    end

    current_day_context = Context.for_current_day # E.g. "@tuesday"
    current_day_tasks = incomplete_tasks.select { |task| task.contexts.include?(current_day_context) }
    tomorrow_tasks = incomplete_tasks.select { |task| task.contexts.include?(Context::TOMORROW) }
    (current_day_tasks + tomorrow_tasks).uniq.each do |task|
      task.contexts -= [current_day_context, Context::TOMORROW]
      task.schedule
    end

    todo_repo.commit_todo_file("Progress scheduled tasks") && todo_repo.push

    if yesterday_tasks.any?
      untagged_with_yesterday = yesterday_tasks.length
      RakeLogger.info "#{untagged_with_yesterday} #{"task".pluralize(untagged_with_yesterday)} untagged with @yesterday"
    end

    if today_tasks.any?
      unscheduled = today_tasks.length
      RakeLogger.info "#{unscheduled} #{"task".pluralize(unscheduled)} moved from @today -> @yesterday"
    end

    if current_day_tasks.any?
      scheduled = current_day_tasks.length
      RakeLogger.info "#{scheduled} #{"task".pluralize(scheduled)} moved from #{current_day_context} -> @today"
    end

    if tomorrow_tasks.any?
      scheduled = tomorrow_tasks.length
      RakeLogger.info "#{scheduled} #{"task".pluralize(scheduled)} moved from @tomorrow -> @today"
    end

    total_progressed = (yesterday_tasks + today_tasks + current_day_tasks + tomorrow_tasks).uniq.length
    RakeLogger.info "Total tasks progressed: #{total_progressed}"
  end
end
