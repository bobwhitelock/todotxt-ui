module RepoUtils
  def mock_todo_repo(*tasks)
    temp_file = Tempfile.new
    tasks.each do |task|
      temp_file << task << "\n"
    end
    temp_file.write
    temp_file.rewind
    TodoRepo.new(temp_file.path)
  end

  def expect_tasks_saved(todo_repo, expected_raw_tasks)
    # Assert given tasks are present in both the given TodoRepo, and a fresh
    # TodoRepo created for the same todo_file (i.e. these tasks have also been
    # saved to disk).
    expect_tasks_equal(todo_repo, expected_raw_tasks)
    expect_tasks_equal(TodoRepo.reload(todo_repo), expected_raw_tasks)
  end

  private

  def expect_tasks_equal(todo_repo, expected_raw_tasks)
    expected_tasks = expected_raw_tasks.map do |raw_task|
      Todo::Task.new(raw_task)
    end
    expect(todo_repo.tasks).to eq(expected_tasks)
  end
end
