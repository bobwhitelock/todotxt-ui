class DeltaApplier
  class UnknownDelta < StandardError; end

  def self.apply(deltas:, todo_repo:)
    deltas.each do |delta|
      case delta.type
      when Delta::ADD
        today = Time.now.strftime('%F')
        new_tasks = delta.arguments.first.lines.map(&:strip).reject(&:empty?)
        new_tasks.each do |task|
          task_with_timestamp = "#{today} #{task}"
          todo_repo.tasks << task_with_timestamp
        end
        commit_message = 'Create task(s)'
      when Delta::UPDATE
        old_task = delta.arguments.first
        new_task = delta.arguments.second
        todo_repo.tasks.delete_if do |t|
          t.raw.strip == old_task
        end
        todo_repo.tasks << new_task
        commit_message = 'Update task'
      when Delta::DELETE
        task = delta.arguments.first
        todo_repo.tasks.delete_if do |t|
          t.raw.strip == task
        end
        commit_message = 'Delete task'
      when Delta::COMPLETE
        task = delta.arguments.first
        matching_task = todo_repo.tasks.find do |t|
          t.raw.strip == task
        end
        matching_task.do! if matching_task
        commit_message = 'Complete task'
      when Delta::SCHEDULE
        task = delta.arguments.first
        todo_repo.tasks.delete_if do |t|
          t.raw.strip == task
        end
        todo_repo.tasks << task.strip + ' @today'
        commit_message = 'Add task to today list'
      when Delta::UNSCHEDULE
        task = delta.arguments.first
        todo_repo.tasks.delete_if do |t|
          t.raw.strip == task
        end
        todo_repo.tasks << task.gsub(/\s+@today\s+/, ' ').strip
        commit_message ='Remove task from today list'
      else
        raise UnknownDelta
      end

      todo_repo.tasks.save!
      todo_repo.commit_todo_file(commit_message)
      delta.update!(status: Delta::APPLIED)
    end
  end
end
