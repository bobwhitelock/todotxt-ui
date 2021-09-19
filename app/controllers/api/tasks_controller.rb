class Api::TasksController < ApplicationController
  before_action :set_default_response_format

  def show
    render_tasks
  end

  def create
    type = params[:type]
    arguments = params[:arguments]
    Delta.create!(type: type, arguments: arguments)
    render_tasks
  end

  private

  def set_default_response_format
    request.format = :json
  end

  def render_tasks
    todo_repos.each do |repo|
      # TODO: DeltaApplier modifying repo instance in place rather than
      # returning new one is a gotcha, only reason this works and can be seen
      # in response is because of caching in `todo_repos` below.
      DeltaApplier.apply(
        todo_repo: repo,
        deltas: Delta.pending,
        commit: false
      )
    end

    render json: {
      data: todo_repos.map do |repo|
        {
          fileName: repo.file_name,
          tasks: repo.list.map(&:to_json)
        }
      end
    }
  end

  def todo_repos
    @_todo_repos ||= YAML.safe_load(Figaro.env.TODO_FILES!).map do |file_path|
      TodoRepo.new(file_path)
    end
  end
end
