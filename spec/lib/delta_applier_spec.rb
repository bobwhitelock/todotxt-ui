require "rails_helper"
require "support/repo_utils"

RSpec.describe DeltaApplier do
  include RepoUtils

  describe ".apply" do
    it "handles `add` delta" do
      now = Time.local(2020, 6, 6)
      Timecop.freeze(now)
      delta = create(
        :delta,
        type: Delta::ADD,
        arguments: ["some task\nanother task"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo("other task")

      expect(todo_repo).to receive(:commit_todo_file).with("Create task(s)")
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "other task",
        "2020-06-06 some task",
        "2020-06-06 another task"
      ])
      expect(delta.reload).to be_applied
    end

    # TODO also test update delta with only one argument is gracefully handled?
    it "handles `update` delta" do
      delta = create(
        :delta,
        type: Delta::UPDATE,
        arguments: ["old task", "new task"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo("other task", "old task")

      expect(todo_repo).to receive(:commit_todo_file).with("Update task")
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ["other task", "new task"])
      expect(delta.reload).to be_applied
    end

    it "handles `delete` delta" do
      delta = create(
        :delta,
        type: Delta::DELETE,
        arguments: ["some task"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo("other task", "some task")

      expect(todo_repo).to receive(:commit_todo_file).with("Delete task")
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ["other task"])
      expect(delta.reload).to be_applied
    end

    it "handles `complete` delta" do
      now = Time.local(2020, 6, 6)
      Timecop.freeze(now)
      delta = create(
        :delta,
        type: Delta::COMPLETE,
        arguments: ["2020-05-05 some task"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo("other task", "2020-05-05 some task")

      expect(todo_repo).to receive(:commit_todo_file).with("Complete task")
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "other task",
        "x 2020-06-06 2020-05-05 some task"
      ])
      expect(delta.reload).to be_applied
    end

    it "handles `schedule` delta" do
      delta = create(
        :delta,
        type: Delta::SCHEDULE,
        arguments: ["some task"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo("other task", "some task")

      expect(todo_repo).to receive(:commit_todo_file).with("Add task to today list")
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ["other task", "some task @today"])
      expect(delta.reload).to be_applied
    end

    it "handles `unschedule` delta" do
      delta = create(
        :delta,
        type: Delta::UNSCHEDULE,
        arguments: ["some task @today @another-tag"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo("other task", "some task @today @another-tag")

      expect(todo_repo).to receive(:commit_todo_file).with("Remove task from today list")
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ["other task", "some task @another-tag"])
      expect(delta.reload).to be_applied
    end

    it "handles multiple deltas" do
      now = Time.local(2020, 6, 6)
      Timecop.freeze(now)
      deltas = (1..3).map { |i|
        create(
          :delta,
          type: Delta::ADD,
          arguments: ["some task #{i}"],
          status: Delta::UNAPPLIED
        )
      }
      todo_repo = mock_todo_repo("other task")

      expect(todo_repo).to receive(:commit_todo_file).thrice.with("Create task(s)")
      DeltaApplier.apply(deltas: deltas, todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        "other task",
        "2020-06-06 some task 1",
        "2020-06-06 some task 2",
        "2020-06-06 some task 3"
      ])
      deltas_applied = deltas.map { |d| d.reload.applied? }
      expect(deltas_applied).to eq([true] * 3)
    end

    it "handles delta with no effect" do
      # Update Delta with old task not present in repo should have no effect.
      delta = create(:delta, type: Delta::UPDATE, arguments: ["foo", "bar"])
      todo_repo = mock_todo_repo("other task")

      expect(todo_repo).not_to receive(:commit_todo_file)
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ["other task"])
      expect(delta.reload).to be_applied
    end

    it "handles no deltas" do
      todo_repo = mock_todo_repo("other task")

      expect(todo_repo).not_to receive(:commit_todo_file)
      DeltaApplier.apply(deltas: [], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ["other task"])
    end

    it "handles unknown delta type; sets `invalid` status" do
      delta = build(:delta, type: "unknown")
      todo_repo = mock_todo_repo

      expect(todo_repo).not_to receive(:commit_todo_file)
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect(delta.reload).to be_invalid
    end

    it "handles all delta types with any arguments" do
      Delta::TYPES.each do |type|
        delta = create(:delta, type: type, arguments: ["arg"] * 10)
        todo_repo = mock_todo_repo
        allow(todo_repo).to receive(:commit_todo_file)

        expect {
          DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)
        }.not_to raise_error
      end
    end

    # TODO test behaviour with/without committing better - do above tests in
    # generic way so can reuse these in both situations, and actually check all
    # behaviour still correct?
    context "when `commit: false` passed" do
      it "leaves todo repo on disk unchanged" do
        Delta::TYPES.each do |type|
          todo_repo = mock_todo_repo("some task")
          delta = create(
            :delta,
            type: type,
            arguments: ["some task", "another arg"]
          )

          expect(todo_repo.tasks).not_to receive(:save!)
          expect(todo_repo).not_to receive(:commit_todo_file)
          DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo, commit: false)
          expect(delta.reload).to be_unapplied
        end
      end
    end

    # TODO improve handling of random whitespace everywhere - or, do this in
    # spec for todo_repo (apart from schedule types, which are handled by
    # DeltaApplier)
    # TODO test no task found for all deltas - can do in generic way
    # TODO handle delta with no arguments? So don't blow up in that case?
    # TODO test every Delta works when multiple matching tasks?
  end
end
