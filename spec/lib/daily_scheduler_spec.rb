require "rails_helper"
require "support/repo_utils"
require "support/stub_git"

RSpec.describe DailyScheduler do
  include RepoUtils

  before do
    allow(Git).to receive(:open).and_return(StubGit.new)
  end

  describe ".progress" do
    before :each do
      now = Time.local(2021, 2, 9) # This is a Tuesday.
      Timecop.freeze(now)
    end

    it "removes tag from tasks tagged with @yesterday" do
      todo_repo = mock_single_file_todo_repo(
        "some important task @yesterday",
        "other task",
        "another important task @yesterday scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("2 tasks untagged with @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("Total tasks progressed: 2").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task",
        "other task",
        "another important task scheduled:1"
      ])
    end

    it "unschedules tasks tagged with @today" do
      todo_repo = mock_single_file_todo_repo(
        "some important task @today",
        "other task",
        "another important task @today scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("2 tasks moved from @today -> @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("Total tasks progressed: 2").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task scheduled:1 @yesterday",
        "other task",
        "another important task scheduled:2 @yesterday"
      ])
    end

    it "schedules tasks tagged with @tomorrow for today" do
      todo_repo = mock_single_file_todo_repo(
        "some important task @tomorrow",
        "other task",
        "another important task @tomorrow scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("2 tasks moved from @tomorrow -> @today").ordered
      expect(RakeLogger).to receive(:info).with("Total tasks progressed: 2").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task @today",
        "other task",
        "another important task scheduled:1 @today"
      ])
    end

    it "schedules tasks tagged with current day of the week for today" do
      todo_repo = mock_single_file_todo_repo(
        "some important task @tuesday",
        "other task",
        "another important task @wednesday scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("1 task moved from @tuesday -> @today").ordered
      expect(RakeLogger).to receive(:info).with("Total tasks progressed: 1").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task @today",
        "other task",
        "another important task @wednesday scheduled:1"
      ])
    end

    it "schedules tasks due today for today" do
      todo_repo = mock_single_file_todo_repo(
        "some important task due:2021-02-09",
        "other task",
        "another important task due:2021-02-10 scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("1 task due on 2021-02-09 tagged with @today").ordered
      expect(RakeLogger).to receive(:info).with("Total tasks progressed: 1").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task due:2021-02-09 @today",
        "other task",
        "another important task due:2021-02-10 scheduled:1"
      ])
    end

    it "handles all transitions in combination" do
      # Some of these combinations of contexts on a single Task are probably
      # not that useful in practise, but should still be handled correctly.
      todo_repo = mock_single_file_todo_repo(
        "task 1 @yesterday",
        "task 2 @today scheduled:2",
        "task 3 @tomorrow",
        "task 4 @tuesday",
        "task 5 due:2021-02-09",
        "task 6 @tomorrow @tuesday",
        "task 7 @today @tomorrow",
        "task 8 @yesterday @today @tomorrow @tuesday due:2021-02-09"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("2 tasks untagged with @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("3 tasks moved from @today -> @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("4 tasks moved from @tomorrow -> @today").ordered
      expect(RakeLogger).to receive(:info).with("3 tasks moved from @tuesday -> @today").ordered
      expect(RakeLogger).to receive(:info).with("2 tasks due on 2021-02-09 tagged with @today").ordered
      expect(RakeLogger).to receive(:info).with("Total tasks progressed: 8").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "task 1",
        "task 2 scheduled:3 @yesterday",
        "task 3 @today",
        "task 4 @today",
        "task 5 due:2021-02-09 @today",
        "task 6 @today",
        "task 7 scheduled:1 @yesterday @today",
        "task 8 due:2021-02-09 scheduled:1 @yesterday @today"
      ])
    end
  end
end
