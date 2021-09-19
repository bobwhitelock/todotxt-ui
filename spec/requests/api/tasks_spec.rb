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
      repos = mock_multiple_todo_repos([
        ["a task", "another task", "x a complete task"],
        ["a backlog task", "another backlog task"]
      ])

      get "/api/tasks", headers: basic_auth_header

      expect(response.status).to eq(200)
      expect(raw_tasks_from_response).to eq([
        {
          fileName: repos[0].file_name,
          tasks: ["a task", "another task", "x a complete task"]
        },
        {
          fileName: repos[1].file_name,
          tasks: ["a backlog task", "another backlog task"]
        }
      ])
    end

    it "includes changes from unapplied deltas" do
      mock_auth_config
      repo = mock_todo_repo("a task")
      create(:delta, type: :add, arguments: ["another task"])
      now = Time.local(2021, 2, 9)
      Timecop.freeze(now)

      get "/api/tasks", headers: basic_auth_header

      expect(response.status).to eq(200)
      expect(raw_tasks_from_response).to eq([{
        fileName: repo.file_name,
        tasks: ["a task", "2021-02-09 another task"]
      }])
    end
  end

  # TODO Also test POST with invalid task - should return 422
  describe "POST /api/tasks" do
    it "creates a delta for the given change and returns the new tasks" do
      mock_auth_config
      repo = mock_todo_repo("a task")

      post_data = {
        type: Delta::UPDATE,
        arguments: ["a task", "updated task"]
      }
      post "/api/tasks", headers: basic_auth_header, params: post_data

      expect(response.status).to eq(200)
      expect(raw_tasks_from_response).to eq([{
        fileName: repo.file_name,
        tasks: ["updated task"]
      }])
    end
  end
end
