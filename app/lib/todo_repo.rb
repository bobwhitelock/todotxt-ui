class TodoRepo
  attr_reader :todo_file
  delegate :push, :pull, to: :repo

  def initialize(todo_file)
    @todo_file = todo_file
  end

  def tasks
    @_tasks ||= Todo::List.new(todo_file)
  end

  def reload
    @_tasks = nil
    self
  end

  def raw_tasks
    tasks.map do |task|
      task.respond_to?(:raw) ? task.raw.strip : task.strip
    end
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
