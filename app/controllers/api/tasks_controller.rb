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
    DeltaApplier.apply(
      todo_repo: todo_repo,
      deltas: Delta.pending,
      commit: false
    )

    render json: {data: todo_repo.list.map(&:to_json)}
  end

  def todo_repo
    @_todo_repo ||= TodoRepo.new(Figaro.env.TODO_FILE!)
  end
end
