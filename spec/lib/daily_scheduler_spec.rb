require "rails_helper"
require "support/repo_utils"
require "support/stub_git"

RSpec.describe DailyScheduler do
  include RepoUtils

  before do
    allow(Git).to receive(:open).and_return(StubGit.new)
  end

  describe ".progress" do
    it "removes tag from tasks tagged with @yesterday" do
      todo_repo = mock_todo_repo(
        "some important task @yesterday",
        "other task",
        "another important task @yesterday scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("2 tasks untagged with @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("0 tasks unscheduled").ordered
      expect(RakeLogger).to receive(:info).with("0 tasks scheduled for today").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task",
        "other task",
        "another important task scheduled:1"
      ])
    end

    it "unschedules tasks tagged with @today" do
      todo_repo = mock_todo_repo(
        "some important task @today",
        "other task",
        "another important task @today scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("0 tasks untagged with @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("2 tasks unscheduled").ordered
      expect(RakeLogger).to receive(:info).with("0 tasks scheduled for today").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task scheduled:1 @yesterday",
        "other task",
        "another important task scheduled:2 @yesterday"
      ])
    end

    it "schedules tasks tagged with @tomorrow for today" do
      todo_repo = mock_todo_repo(
        "some important task @tomorrow",
        "other task",
        "another important task @tomorrow scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("0 tasks untagged with @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("0 tasks unscheduled").ordered
      expect(RakeLogger).to receive(:info).with("2 tasks scheduled for today").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task @today",
        "other task",
        "another important task scheduled:1 @today"
      ])
    end

    it "schedules tasks tagged with current day of the week for today" do
      now = Time.local(2021, 2, 9) # This is a Tuesday.
      Timecop.freeze(now)
      todo_repo = mock_todo_repo(
        "some important task @tuesday",
        "other task",
        "another important task @wednesday scheduled:1"
      )

      expect(todo_repo).to receive(:commit_todo_file).with("Progress scheduled tasks").and_call_original
      expect(todo_repo).to receive(:push)
      expect(RakeLogger).to receive(:info).with("0 tasks untagged with @yesterday").ordered
      expect(RakeLogger).to receive(:info).with("0 tasks unscheduled").ordered
      expect(RakeLogger).to receive(:info).with("1 task scheduled for today").ordered
      DailyScheduler.progress(todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "some important task @today",
        "other task",
        "another important task @wednesday scheduled:1"
      ])
    end
  end
end
