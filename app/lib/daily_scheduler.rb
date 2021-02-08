class DailyScheduler
  class << self
    def progress(todo_repo:)
      DailyScheduler.new(todo_repo: todo_repo).progress
    end

    def transitions
      # Order is important here, since if an earlier entry transitions to a
      # context that is then handled by a later one, the later transition will
      # also be applied to the same task within a single scheduler run, which
      # is probably undesirable.
      [
        {
          from_contexts: [Context::YESTERDAY],
          to_context: nil
        },
        {
          from_contexts: [Context::TODAY],
          to_context: Context::YESTERDAY,
          bump_scheduled: true
        },
        {
          from_contexts: [Context::TOMORROW, Context.for_current_day],
          from_due: Date.today,
          to_context: Context::TODAY
        }
      ].map { |t| OpenStruct.new(**t) }
    end
  end

  attr_reader :todo_repo
  attr_reader :messages

  delegate :incomplete_tasks, to: :todo_repo

  def initialize(todo_repo:)
    @todo_repo = todo_repo
    @messages = []
  end

  def progress
    all_progressed_tasks = Set.new
    DailyScheduler.transitions.each do |transition|
      transition_tasks = select_tasks_for_transition(transition)
      all_progressed_tasks.merge(transition_tasks)
      process_transition(transition, transition_tasks)
    end

    todo_repo.commit_todo_file("Progress scheduled tasks") && todo_repo.push

    messages.each { |message| RakeLogger.info(message) }
    RakeLogger.info "Total tasks progressed: #{all_progressed_tasks.count}"
  end

  private

  def select_tasks_for_transition(transition)
    context_tasks = transition.from_contexts.flat_map { |from_context|
      select_tasks_for_context(from_context, transition)
    }
    due_tasks = select_tasks_for_due(transition)
    Set.new([*context_tasks, *due_tasks])
  end

  def select_tasks_for_context(context, transition)
    context_tasks = incomplete_tasks.select { |task|
      task.contexts.include?(context)
    }

    log_context_transition(
      from: context,
      to: transition.to_context,
      tasks: context_tasks
    )

    context_tasks
  end

  def log_context_transition(from:, to:, tasks:)
    message_content = if to
      "moved from #{from} -> #{to}"
    else
      "untagged with #{from}"
    end
    log_transitioned_tasks(tasks, message_content)
  end

  def select_tasks_for_due(transition)
    due_date = transition.from_due
    return [] unless due_date
    due_tasks = incomplete_tasks.select { |task| task.metadata[:due] == due_date }
    log_due_transition(transition, due_tasks)
    due_tasks
  end

  def log_due_transition(transition, tasks)
    log_transitioned_tasks(
      tasks,
      "due on #{transition.from_due} tagged with #{transition.to_context}"
    )
  end

  def process_transition(transition, tasks)
    tasks.each do |task|
      bump_scheduled(task) if transition.bump_scheduled
      task.contexts -= transition.from_contexts
      task.contexts += [transition.to_context].compact
    end
  end

  def bump_scheduled(task)
    metadata = task.metadata
    scheduled = metadata.fetch(:scheduled, 0).to_i
    task.metadata = {**metadata, scheduled: scheduled + 1}
  end

  def log_transitioned_tasks(tasks, message_content)
    return unless tasks.any?
    count = tasks.count
    messages.append(
      [count, "task".pluralize(count), message_content].join(" ")
    )
  end
end
