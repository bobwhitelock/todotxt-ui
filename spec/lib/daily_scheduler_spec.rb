require "rails_helper"
require "support/repo_utils"
require "support/stub_git"

RSpec.describe DailyScheduler do
  include RepoUtils

  before do
    allow(Git).to receive(:open).and_return(StubGit.new)
  end

  describe ".progress" do
    it "unschedules tasks tagged with @today" do
      todo_repo = mock_todo_repo(
        "some important task @today",
        "other task",
        "another important task @today scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Automatically clear today list").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("2 tasks cleared")
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task scheduled:1",
        "other task",
        "another important task scheduled:2"
      ])
    end
  end
end
