class DeltaApplier
  # TODO Reconsider API here - change defaulting to true, maybe have 2 separate
  # public methods rather than toggling on a flag.
  def self.apply(deltas:, todo_repo:, commit: true)
    deltas.each do |delta|
      DeltaApplier.new(
        delta: delta,
        todo_repo: todo_repo,
        commit: commit
      ).apply
    end
  end

  attr_reader :delta, :todo_repo, :commit

  def initialize(delta:, todo_repo:, commit:)
    @delta = delta
    @todo_repo = todo_repo
    @commit = commit
  end

  def apply
    original_raw_tasks = todo_repo.raw_tasks
    handle_delta
    save_delta_change(original_raw_tasks) if commit
  end

  private

  DELTA_COMMIT_MESSAGES = {
    Delta::ADD => "Create task(s)",
    Delta::UPDATE => "Update task",
    Delta::DELETE => "Delete task",
    Delta::COMPLETE => "Complete task",
    Delta::SCHEDULE => "Add task to today list",
    Delta::UNSCHEDULE => "Remove task from today list"
  }

  def commit_message
    DELTA_COMMIT_MESSAGES[delta.type]
  end

  def handle_delta
    handle_message = "handle_#{delta.type}"
    if respond_to?(handle_message, include_all: true)
      send(handle_message)
    else
      handle_invalid_delta
    end
  end

  def handle_add
    today = Time.now.strftime("%F")
    new_tasks = delta.arguments.first.lines.map(&:strip).reject(&:empty?)
    new_tasks.each do |task|
      task_with_timestamp = "#{today} #{task}"
      todo_repo.add_task(task_with_timestamp)
    end
  end

  def handle_update
    old_task = delta.arguments.first
    new_task = delta.arguments.second.squish
    todo_repo.replace_task(old_task, new_task)
  end

  def handle_delete
    task = delta.arguments.first
    todo_repo.delete_task(task)
  end

  def handle_complete
    task = delta.arguments.first
    todo_repo.complete_task(task)
  end

  def handle_schedule
    task = delta.arguments.first
    todo_repo.replace_task(task, task.strip + " @today")
  end

  def handle_unschedule
    task = delta.arguments.first
    todo_repo.replace_task(task, task.gsub(/\s+@today\s*/, " "))
  end

  def handle_invalid_delta
    delta.update!(status: Delta::INVALID)
  end

  def save_delta_change(original_raw_tasks)
    return unless commit_message

    # Need to save and then reload TodoRepo when checking if tasks have
    # changed, as `todo-txt` Gem does not change raw tasks for all changes,
    # e.g. a completed Task keeps the same raw version until it has been
    # saved and reloaded from disk.
    todo_repo.tasks.save!
    tasks_changed = TodoRepo.reload(todo_repo).raw_tasks != original_raw_tasks
    todo_repo.commit_todo_file(commit_message) if tasks_changed
    delta.update!(status: Delta::APPLIED)
  end
end
