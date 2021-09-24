class TodoRepo
  delegate :push, to: :repo

  def initialize(todo_files)
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

    @files_to_lists = todo_files.map do |todo_file|
      [todo_file, Todotxt::List.load(todo_file)]
    end.to_h
  end

  def files
    files_to_lists.keys
  end

  def list_for_file(file)
    files_to_lists.fetch(file)
  end

  # XXX update/replace usage
  def incomplete_tasks
    list.select(&:incomplete?)
  end

  def add_task(file:, raw_task:)
    list_for_file(file) << raw_task
  end

  def delete_task(file:, raw_task:)
    list_for_file(file).delete_if { |t| t.equals_raw_task(raw_task) }
  end

  def replace_task(file:, old_raw_task:, new_raw_task:)
    map_task(file: file, raw_task: old_raw_task) do |task|
      task.raw = new_raw_task
    end
  end

  def complete_task(file:, raw_task:)
    map_task(file: file, raw_task: raw_task, &:complete!)
  end

  def map_task(file:, raw_task:, &block)
    list_for_file(file).select { |t| t.equals_raw_task(raw_task) }.map(&block)
  end

  def reset_to_origin
    repo.fetch
    repo.reset_hard("origin/master")
  end

  def commit_todo_files(message)
    return false unless any_list_dirty?
    lists.each do |list|
      list.save
      repo.add(list.file)
    end
    repo.commit(message)
    true
  end

  private

  attr_reader :files_to_lists

  def lists
    files_to_lists.values
  end

  def any_list_dirty?
    lists.map { |list| list.dirty? }.any?
  end

  def repo
    @_repo ||=
      begin
        # TODO This won't work if there are no files, and nothing will work as
        # expected if the files are not all in the same repo.
        todo_dir = File.dirname(files.first)
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
