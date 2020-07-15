class DeltaApplier
  # XXX Reconsider API here - change defaulting to true, maybe have 2 separate
  # public methods rather than toggling on a flag.
  def self.apply(deltas:, todo_repo:, commit: true)
    deltas.each do |delta|
      case delta.type
      when Delta::ADD
        today = Time.now.strftime('%F')
        new_tasks = delta.arguments.first.lines.map(&:strip).reject(&:empty?)
        new_tasks.each do |task|
          task_with_timestamp = "#{today} #{task}"
          todo_repo.add_task(task_with_timestamp)
        end
        commit_message = 'Create task(s)'
      when Delta::UPDATE
        old_task = delta.arguments.first
        new_task = delta.arguments.second
        todo_repo.replace_task(old_task, new_task)
        commit_message = 'Update task'
      when Delta::DELETE
        task = delta.arguments.first
        todo_repo.delete_task(task)
        commit_message = 'Delete task'
      when Delta::COMPLETE
        task = delta.arguments.first
        todo_repo.complete_task(task)
        commit_message = 'Complete task'
      when Delta::SCHEDULE
        task = delta.arguments.first
        todo_repo.replace_task(task, task.strip + ' @today')
        commit_message = 'Add task to today list'
      when Delta::UNSCHEDULE
        task = delta.arguments.first
        todo_repo.replace_task(task, task.gsub(/\s+@today\s*/, ' '))
        commit_message ='Remove task from today list'
      else
        delta.update!(status: Delta::INVALID)
        next
      end

      if commit
        todo_repo.tasks.save!
        todo_repo.commit_todo_file(commit_message)
        delta.update!(status: Delta::APPLIED)
      end
    end
  end
end
