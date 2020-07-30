require 'rails_helper'
require 'support/repo_utils'

RSpec.describe TodoRepo do
  include RepoUtils
  # TODO Add tests for rest of behaviour of TodoRepo.

  describe '#replace_task' do
    it 'replaces old task with new task' do
      todo_repo = mock_todo_repo('other task', 'old task')

      todo_repo.replace_task('old task', 'new task')

      expect_tasks_saved(todo_repo, ['other task', 'new task'])
    end

    it 'does nothing when old task not present in repo' do
      todo_repo = mock_todo_repo('other task')

      todo_repo.replace_task('old task', 'new task')

      expect_tasks_saved(todo_repo, ['other task'])
    end

    it 'works when tasks include arbitrary whitespace' do
      todo_repo = mock_todo_repo('other task', '  old task ')

      todo_repo.replace_task(' old task   ', '  new task  ')

      expect_tasks_saved(todo_repo, ['other task', 'new task'])
    end
  end
end
