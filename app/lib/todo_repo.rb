class TodoRepo
  attr_reader :todo_file
  delegate :push, to: :repo

  def initialize(todo_file)
    @todo_file = todo_file
  end

  # Create a new TodoRepo from given TodoRepo, but with tasks reloaded fresh
  # from disk.
  def self.reload(other_todo_repo)
    TodoRepo.new(other_todo_repo.todo_file)
  end

  def tasks
    @_tasks ||= Todo::List.new(todo_file)
  end

  def raw_tasks
    tasks.map { |task| task.raw.strip }
  end

  def add_task(raw_task)
    tasks << Todo::Task.new(raw_task.strip)
  end

  def delete_task(raw_task)
    tasks.delete_if do |t|
      t.raw.strip == raw_task.strip
    end
  end

  def replace_task(old_raw_task, new_raw_task)
    # TODO Actually replace inline rather than deleting old and then adding
    # (i.e. appending at bottom of file) new task -
    # https://github.com/bobwhitelock/todotxt-ui/issues/17.
    if tasks.map { |t| t.raw.strip }.include?(old_raw_task.strip)
      delete_task(old_raw_task)
      add_task(new_raw_task)
    end
  end

  def complete_task(raw_task)
    matching_task = tasks.find { |t|
      t.raw.strip == raw_task.strip
    }
    matching_task&.do!
  end

  def all_projects
    extract_tag(:projects)
  end

  def all_contexts
    extract_tag(:contexts)
  end

  def reset_to_origin
    repo.fetch
    repo.reset_hard("origin/master")
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
        # TODO Handle this being nil, i.e. repo not found.
        repo_dir = find_repo_root_dir(todo_dir)
        repo = Git.open(repo_dir)
        repo.config("user.name", "Todotxt UI")
        repo.config("user.email", Figaro.env.GIT_EMAIL!)
        repo
      end
  end

  def find_repo_root_dir(child_dir)
    path = Pathname.new(child_dir)
    until path.root?
      git_path = path.join(".git")
      return path if git_path.exist?
      path = path.parent
    end
  end

  def extract_tag(tag_type)
    tasks.flat_map(&tag_type).uniq.map { |p| p[1..-1] }
  end
end
