class TodoRepo
  attr_reader :list
  delegate :all_contexts, :all_projects, to: :list
  delegate :push, to: :repo

  def initialize(todo_file)
    # TODO Defining this global config here seems the best place to both have
    # tests pass without jumping through hoops, and avoid this warning which
    # occurs if put this in an initializer: `DEPRECATION WARNING:
    # Initialization autoloaded the constants Todotxt::Config, Todotxt::Task,
    # and TaskWrapper.`. But might be a better place and/or could make this
    # config not global.
    Todotxt.config = Todotxt::Config.new(
      parse_code_blocks: true,
      task_class: TaskWrapper
    )

    @list = Todotxt::List.load(todo_file)
  end

  def incomplete_tasks
    list.select(&:incomplete?)
  end

  def add_task(raw_task)
    list << raw_task
  end

  def delete_task(raw_task)
    list.delete_if { |t| t.equals_raw_task(raw_task) }
  end

  def replace_task(old_raw_task, new_raw_task)
    map_task(old_raw_task) { |task| task.raw = new_raw_task }
  end

  def complete_task(raw_task)
    map_task(raw_task, &:complete!)
  end

  def map_task(raw_task, &block)
    list.select { |t| t.equals_raw_task(raw_task) }.map(&block)
  end

  def reset_to_origin
    repo.fetch
    repo.reset_hard("origin/master")
  end

  def commit_todo_file(message)
    return false unless list.dirty?
    list.save
    repo.add(todo_file)
    repo.commit(message)
    true
  end

  private

  def todo_file
    list.file
  end

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
end
