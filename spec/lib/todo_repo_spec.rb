require "rails_helper"
require "support/repo_utils"

RSpec.describe TodoRepo do
  include RepoUtils
  # TODO Add tests for rest of behaviour of TodoRepo.

  describe "#replace_task" do
    it "replaces old task with new task" do
      todo_repo = mock_single_file_todo_repo("other task", "old task")
      file = todo_repo.files.first
      list = todo_repo.list_for_file(file)

      todo_repo.replace_task(
        file: file, old_raw_task: "old task", new_raw_task: "new task"
      )

      expect(list.raw_tasks).to eq(["other task", "new task"])
    end

    it "does nothing when old task not present in repo" do
      todo_repo = mock_single_file_todo_repo("other task")
      file = todo_repo.files.first
      list = todo_repo.list_for_file(file)

      todo_repo.replace_task(
        file: file, old_raw_task: "old task", new_raw_task: "new task"
      )

      expect(list.raw_tasks).to eq(["other task"])
    end

    it "works when tasks include arbitrary whitespace" do
      todo_repo = mock_single_file_todo_repo("other task", "  old task ")
      file = todo_repo.files.first
      list = todo_repo.list_for_file(file)

      todo_repo.replace_task(
        file: file, old_raw_task: " old task   ", new_raw_task: "  new task  "
      )

      expect(list.raw_tasks).to eq(["other task", "new task"])
    end
  end
end
