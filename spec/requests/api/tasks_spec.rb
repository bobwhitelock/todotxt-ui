require "base64"

require "rails_helper"
require "support/repo_utils"
require "support/api_test_utils"

RSpec.describe "/api/tasks" do
  include RepoUtils
  include ApiTestUtils

  def raw_tasks_from_response
    response_json = JSON.parse(response.body).deep_symbolize_keys
    data = response_json[:data]
    data.each do |file_data|
      file_data[:tasks] = file_data[:tasks].map { |t| t[:raw] }
    end
    data
  end

  describe "GET /api/tasks" do
    it "returns all tasks in the repo" do
      mock_auth_config
      repo = mock_multi_file_todo_repo([
        ["a task", "another task", "x a complete task"],
        ["a backlog task", "another backlog task"]
      ])

      get "/api/tasks", headers: basic_auth_header

      expect(response.status).to eq(200)
      expect(raw_tasks_from_response).to eq([
        {
          filePath: repo.files.first,
          tasks: ["a task", "another task", "x a complete task"]
        },
        {
          filePath: repo.files.second,
          tasks: ["a backlog task", "another backlog task"]
        }
      ])
    end

    it "includes changes from unapplied deltas" do
      mock_auth_config
      repo = mock_single_file_todo_repo("a task")
      file = repo.files.first
      create(:delta, type: :add, arguments: {task: "another task", file: file})
      now = Time.local(2021, 2, 9)
      Timecop.freeze(now)

      get "/api/tasks", headers: basic_auth_header

      expect(response.status).to eq(200)
      expect(raw_tasks_from_response).to eq([{
        filePath: file,
        tasks: ["a task", "2021-02-09 another task"]
      }])
    end
  end

  # TODO Also test POST with invalid task - should return 422
  describe "POST /api/tasks" do
    it "creates a delta for the given change and returns the new tasks" do
      mock_auth_config
      repo = mock_single_file_todo_repo("a task")
      file = repo.files.first

      post_data = {
        type: Delta::UPDATE,
        arguments: {task: "a task", new_task: "updated task", file: file}
      }
      post "/api/tasks", headers: basic_auth_header, params: post_data

      expect(response.status).to eq(200)
      expect(raw_tasks_from_response).to eq([{
        filePath: file,
        tasks: ["updated task"]
      }])
    end
  end
end
