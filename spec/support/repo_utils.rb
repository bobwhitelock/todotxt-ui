module RepoUtils
  def mock_multiple_todo_repos(task_lists)
    repos = task_lists.map do |tasks|
      mock_todo_repo(*tasks)
    end
    # Overrides last mocking of same environment variable in `mock_todo_repo`.
    allow(Figaro.env).to receive("TODO_FILES!").and_return(
      YAML.dump(repos.map { |r| r.list.file })
    )
    repos
  end

  def mock_todo_repo(*tasks)
    temp_file = Tempfile.new
    tasks.each do |task|
      temp_file << task << "\n"
    end
    temp_file.write
    temp_file.rewind
    allow(Figaro.env).to receive("TODO_FILES!").and_return(
      YAML.dump([temp_file.path])
    )
    TodoRepo.new(temp_file.path)
  end

  def expect_tasks_saved(todo_repo, expected_raw_tasks)
    # Assert given tasks are present in both the current list and are also
    # present after a reload (i.e. they have also been saved to disk).
    expect(todo_repo.list.raw_tasks).to eq(expected_raw_tasks)
    expect(todo_repo.list.reload.raw_tasks).to eq(expected_raw_tasks)
  end
end
