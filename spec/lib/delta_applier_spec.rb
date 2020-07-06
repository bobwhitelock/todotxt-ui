require 'rails_helper'

RSpec.describe DeltaApplier do
  describe '.apply' do
    it 'handles `add` delta' do
      now = Time.local(2020, 6, 6)
      Timecop.freeze(now)
      delta = create(
        :delta,
        type: Delta::ADD,
        arguments: ["some task\nanother task"],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo('other task')

      expect(todo_repo).to receive(:commit_todo_file).with('Create task(s)')
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        'other task',
        '2020-06-06 some task',
        '2020-06-06 another task',
      ])
      expect(delta.reload.status).to eq(Delta::APPLIED)
    end

    it 'handles `update` delta' do
      delta = create(
        :delta,
        type: Delta::UPDATE,
        arguments: ['old task', 'new task'],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo('other task', 'old task')

      expect(todo_repo).to receive(:commit_todo_file).with('Update task')
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ['other task', 'new task'])
      expect(delta.reload.status).to eq(Delta::APPLIED)
    end

    it 'handles `delete` delta' do
      delta = create(
        :delta,
        type: Delta::DELETE,
        arguments: ['some task'],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo('other task', 'some task')

      expect(todo_repo).to receive(:commit_todo_file).with('Delete task')
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ['other task'])
      expect(delta.reload.status).to eq(Delta::APPLIED)
    end

    it 'handles `complete` delta' do
      now = Time.local(2020, 6, 6)
      Timecop.freeze(now)
      delta = create(
        :delta,
        type: Delta::COMPLETE,
        arguments: ['2020-05-05 some task'],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo('other task', '2020-05-05 some task')

      expect(todo_repo).to receive(:commit_todo_file).with('Complete task')
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      # XXX have to test just the reload here as todotxt gem handles `do!`
      # weirdly - improve how this works to be more consistent - move all
      # mutations tasks into TodoRepo?
      expect(todo_repo.reload.raw_tasks).to eq([
        'other task',
        'x 2020-06-06 2020-05-05 some task'
      ])
      expect(delta.reload.status).to eq(Delta::APPLIED)
    end

    it 'handles `schedule` delta' do
      delta = create(
        :delta,
        type: Delta::SCHEDULE,
        arguments: ['some task'],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo('other task', 'some task')

      expect(todo_repo).to receive(:commit_todo_file).with('Add task to today list')
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ['other task', 'some task @today'])
      expect(delta.reload.status).to eq(Delta::APPLIED)
    end

    it 'handles `unschedule` delta' do
      delta = create(
        :delta,
        type: Delta::UNSCHEDULE,
        arguments: ['some task @today @another-tag'],
        status: Delta::UNAPPLIED
      )
      todo_repo = mock_todo_repo('other task', 'some task @today @another-tag')

      expect(todo_repo).to receive(:commit_todo_file).with('Remove task from today list')
      DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, ['other task', 'some task @another-tag'])
      expect(delta.reload.status).to eq(Delta::APPLIED)
    end

    it 'handles multiple deltas' do
      now = Time.local(2020, 6, 6)
      Timecop.freeze(now)
      deltas = (1..3).map do |i|
        create(
          :delta,
          type: Delta::ADD,
          arguments: ["some task #{i}"],
          status: Delta::UNAPPLIED
        )
      end
      todo_repo = mock_todo_repo('other task')

      expect(todo_repo).to receive(:commit_todo_file).thrice.with('Create task(s)')
      DeltaApplier.apply(deltas: deltas, todo_repo: todo_repo)

      expect_tasks_saved(todo_repo, [
        'other task',
        '2020-06-06 some task 1',
        '2020-06-06 some task 2',
        '2020-06-06 some task 3',
      ])
      delta_statuses = deltas.map {|d| d.reload.status}
      expect(delta_statuses).to eq([Delta::APPLIED] * 3)
    end

    it 'raises for unknown delta type' do
      delta = build(:delta, type: 'unknown')
      todo_repo = mock_todo_repo

      expect do
        DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)
      end.to raise_error(DeltaApplier::UnknownDelta)
    end

    it 'handles all delta types with any arguments' do
      Delta::TYPES.each do |type|
        delta = create(:delta, type: type, arguments: ['arg'] * 10)
        todo_repo = mock_todo_repo
        allow(todo_repo).to receive(:commit_todo_file)

        expect do
          DeltaApplier.apply(deltas: [delta], todo_repo: todo_repo)
        end.not_to raise_error
      end
    end
  end

  def mock_todo_repo(*tasks)
    temp_file = Tempfile.new
    tasks.each do |task|
      temp_file << task << "\n"
    end
    temp_file.write
    temp_file.rewind
    TodoRepo.new(temp_file.path)
  end

  def expect_tasks_saved(todo_repo, tasks)
    expect(todo_repo.raw_tasks).to eq(tasks)
    expect(todo_repo.reload.raw_tasks).to eq(tasks)
  end
end
