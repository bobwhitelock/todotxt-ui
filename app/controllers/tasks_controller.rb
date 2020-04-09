class TasksController < ApplicationController
  def index
    # XXX Don't do this on every request to avoid blocking rendering page.
    todo_repo.pull
    todo_repo.reset_hard('origin/master')

    @filters = filters
    @total_tasks = tasks.by_not_done.length
    @tasks = tasks_to_show.sort_by do |task|
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

  def todo_repo
    @_todo_repo ||=
      begin
        todo_dir = File.dirname(todo_file)
        # XXX Handle this being nil, i.e. repo not found.
        repo_dir = find_repo_root_dir(todo_dir)
        repo = Git.open(repo_dir)
        repo.config('user.name', 'Todotxt UI')
        repo.config('user.email', ENV.fetch('GIT_EMAIL'))
        repo
      end
  end

  def find_repo_root_dir(child_dir)
    path = Pathname.new(child_dir)
    until path.root?
      git_path = path.join('.git')
      return path if git_path.exist?
      path = path.parent
    end
  end

  def tasks_to_show
    to_show = tasks.by_not_done

    filters.each do |filter|
      if filter.start_with?('+')
        to_show = to_show.by_project(filter)
      elsif filter.start_with?('@')
        to_show = to_show.by_context(filter)
      end
    end

    to_show
  end

  def filters
    Array.wrap(params[:filters])
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
      commit_and_push_todo_file
    end

    redirect_back fallback_location: root_path
  end

  def commit_and_push_todo_file
    # XXX Do something clever to group multiple updates in quick succession -
    # either debounce this function or use amend and force push in that
    # situation (latter probably better as more robust).
    todo_repo.add(todo_file)
    todo_repo.commit('Automatically committed change from todotxt-ui')
    # XXX Do this asynchronously to not block returning response.
    todo_repo.push
  end
end
