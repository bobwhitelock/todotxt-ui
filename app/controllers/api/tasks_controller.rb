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
    # TODO: DeltaApplier modifying repo instance in place rather than
    # returning new one is a gotcha, only reason this works and can be seen
    # in response is because of caching in `todo_repo` below.
    DeltaApplier.apply(
      todo_repo: todo_repo,
      deltas: Delta.pending,
      commit: false
    )

    render json: {
      data: todo_repo.files.map do |file_path|
        {
          filePath: file_path,
          tasks: todo_repo.list_for_file(file_path).map(&:to_json)
        }
      end
    }
  end

  def todo_repo
    @_todo_repo ||= TodoRepo.new(YAML.safe_load(Figaro.env.TODO_FILES!))
  end
end
