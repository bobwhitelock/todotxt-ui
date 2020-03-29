class TasksController < ApplicationController
  def index
    @tasks = tasks.by_not_done.sort_by do |task|
      [
        # XXX Only show things due soon first?
        task.tags.fetch(:due, 'z'),
        task.priority || 'Z',
        task.created_on
      ]
    end
  end

  def destroy
    find_task_and do |task|
      tasks.delete_if do |t|
        t.raw == task.raw
      end
    end
  end

  def complete
    find_task_and(&:do!)
  end

  private

  def tasks
    @_tasks ||= Todo::List.new(todo_file)
  end

  def todo_file
    @_todo_file ||= ENV.fetch('TODO_FILE')
  end

  def find_task_and
    raw_task = params[:task]
    task_to_operate_on = tasks.find do |task|
      task.raw.strip == raw_task
    end

    # XXX Flash a message in the else case, something has gone wrong
    if task_to_operate_on
      yield task_to_operate_on
      tasks.save!
    end

    redirect_back fallback_location: root_path
  end
end
