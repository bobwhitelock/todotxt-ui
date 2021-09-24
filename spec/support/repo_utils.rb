module RepoUtils
  def mock_single_file_todo_repo(*tasks)
    mock_multi_file_todo_repo([tasks])
  end

  def mock_multi_file_todo_repo(task_lists)
    files = task_lists.map do |tasks|
      temp_file = Tempfile.new
      tasks.each do |task|
        temp_file << task << "\n"
      end
      temp_file.write
      temp_file.rewind
      temp_file
    end
    file_paths = files.map(&:path)
    allow(Figaro.env).to receive("TODO_FILES!").and_return(
      YAML.dump(file_paths)
    )
    TodoRepo.new(file_paths)
  end

  def expect_tasks_saved(todo_list, expected_raw_tasks)
    # Assert given tasks are present in both the current list and are also
    # present after a reload (i.e. they have also been saved to disk).
    expect(todo_list.raw_tasks).to eq(expected_raw_tasks)
    expect(todo_list.reload.raw_tasks).to eq(expected_raw_tasks)
  end
end
