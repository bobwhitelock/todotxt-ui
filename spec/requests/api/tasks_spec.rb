require "base64"

require "rails_helper"
require "support/repo_utils"

RSpec.describe "/api/tasks" do
  include RepoUtils

  let(:test_username) { "user" }
  let(:test_password) { "password" }

  def mock_auth_config
    allow(Figaro.env).to receive("AUTH_USER!").and_return(test_username)
    allow(Figaro.env).to receive("AUTH_PASSWORD!").and_return(test_password)
  end

  def basic_auth_header
    {Authorization: "Basic #{Base64.encode64("#{test_username}:#{test_password}")}"}
  end

  describe "GET /api/tasks" do
    # XXX Should do anything to the tasks? or leave this to the frontend?
    it "returns all tasks in the repo" do
      mock_auth_config
      mock_todo_repo("a task", "another task", "x a complete task")

      get "/api/tasks", headers: basic_auth_header

      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body).deep_symbolize_keys
      raw_tasks = response_json[:data].map { |t| t[:raw] }
      expect(raw_tasks).to eq(["a task", "another task", "x a complete task"])
    end

    it "includes changes from unapplied deltas" do
      mock_auth_config
      mock_todo_repo("a task")
      create(:delta, type: :add, arguments: ["another task"])
      now = Time.local(2021, 2, 9)
      Timecop.freeze(now)

      get "/api/tasks", headers: basic_auth_header

      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body).deep_symbolize_keys
      raw_tasks = response_json[:data].map { |t| t[:raw] }
      expect(raw_tasks).to eq(["a task", "2021-02-09 another task"])
    end
  end

  # XXX Also test POST with invalid task? Should return 422?
  describe "POST /api/tasks" do
    it "creates a delta for the given change and returns the new tasks" do
      mock_auth_config
      mock_todo_repo("a task")

      post_data = {
        action: Delta::UPDATE,
        arguments: ["a task", "updated task"]
      }
      post "/api/tasks", headers: basic_auth_header, params: post_data

      # XXX DRY this up?
      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body).deep_symbolize_keys
      raw_tasks = response_json[:data].map { |t| t[:raw] }
      expect(raw_tasks).to eq(["updated task"])
    end
  end
end
