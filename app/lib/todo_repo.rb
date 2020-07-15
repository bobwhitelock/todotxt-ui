class TodoRepo
  attr_reader :todo_file
  delegate :push, :pull, to: :repo

  def initialize(todo_file)
    @todo_file = todo_file
  end

  def tasks
    @_tasks ||= Todo::List.new(todo_file)
  end

  def add_task(raw_task)
    tasks << Todo::Task.new(raw_task)
  end

  def delete_task(raw_task)
    tasks.delete_if do |t|
      t.raw.strip == raw_task
    end
  end

  def replace_task(old_raw_task, new_raw_task)
    # XXX Actually replace inline rather than deleting old and then adding
    # (i.e. appending at bottom of file) new task.
    if tasks.map(&:raw).include?(old_raw_task)
      delete_task(old_raw_task)
      add_task(new_raw_task)
    end
  end

  def complete_task(raw_task)
    matching_task = tasks.find do |t|
      t.raw.strip == raw_task
    end
    matching_task.do! if matching_task
  end

  def all_projects
    extract_tag(:projects)
  end

  def all_contexts
    extract_tag(:contexts)
  end

  def reset_to_origin
    repo.fetch
    repo.reset_hard('origin/master')
  end

  def pull_and_reset
    repo.pull
    repo.reset_hard('origin/master')
  end

  def save_and_push(message)
    commit_todo_file(message)
    # XXX Do this asynchronously to not block returning response.
    repo.push
  end

  def commit_todo_file(message)
    repo.add(todo_file)
    repo.commit(message)
  end

  private

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

  def extract_tag(tag_type)
    tasks.flat_map(&tag_type).uniq.map {|p| p[1..-1]}
  end
end
