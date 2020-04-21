class TodoRepo
  def tasks
    @_tasks ||= Todo::List.new(todo_file)
  end

  def pull_and_reset
    repo.pull
    repo.reset_hard('origin/master')
  end

  def save_and_push(message)
    tasks.save!
    commit_and_push_todo_file(message)
  end

  private

  def todo_file
    @_todo_file ||= ENV.fetch('TODO_FILE')
  end

  def repo
    @_repo ||=
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

  def commit_and_push_todo_file(message)
    # XXX Do something clever to group multiple updates in quick succession -
    # either debounce this function or use amend and force push in that
    # situation (latter probably better as more robust).
    repo.add(todo_file)
    repo.commit("#{message} - Todotxt UI")
    # XXX Do this asynchronously to not block returning response.
    repo.push
  end
end
