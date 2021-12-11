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
    handle_delta
    save_delta_change if commit
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
    send(handle_message)
  end

  def handle_add
    today = Time.now.strftime("%F")
    new_tasks = delta.task.lines.map(&:strip).reject(&:empty?)
    new_tasks.each do |task|
      task_with_timestamp = "#{today} #{task}"
      todo_repo.add_task(file: delta.file, raw_task: task_with_timestamp)
    end
  end

  def handle_update
    todo_repo.replace_task(
      file: delta.file, old_raw_task: delta.task, new_raw_task: delta.new_task
    )
  end

  def handle_delete
    todo_repo.delete_task(file: delta.file, raw_task: delta.task)
  end

  def handle_complete
    todo_repo.complete_task(file: delta.file, raw_task: delta.task)
  end

  def handle_schedule
    todo_repo.map_task(file: delta.file, raw_task: delta.task, &:schedule)
  end

  def handle_unschedule
    todo_repo.map_task(file: delta.file, raw_task: delta.task, &:unschedule)
  end

  def save_delta_change
    return unless commit_message
    todo_repo.commit_todo_files(commit_message)
    delta.update!(status: Delta::APPLIED)
  end
end
