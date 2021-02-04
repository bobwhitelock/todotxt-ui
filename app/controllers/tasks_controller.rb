class TasksController < ApplicationController
  before_action :assign_filters, :assign_tags

  def index
    DeltaApplier.apply(
      todo_repo: todo_repo,
      deltas: Delta.pending,
      commit: false
    )

    @total_tasks = todo_repo.incomplete_tasks.length

    @tasks = tasks_to_show.sort_by { |task|
      # Each entry in comparison array should always be of the same type (or
      # nil) for every task, otherwise this can blow up.
      [
        task.today? ? "a" : "b",
        # Compare `due` metadata values as strings, since there is no guarantee
        # that only Dates will be used for these.
        task.metadata.fetch(:due, "zzz").to_s,
        task.priority || "Z",
        task.creation_date || 100.years.from_now,
        task.raw
      ]
    }
    @subtitle = "#{@tasks.size} tasks"
  end

  def new
    @subtitle = "Add Tasks"
  end

  def create
    tasks = params[:new_task].strip
    Delta.create!(type: Delta::ADD, arguments: [tasks]) unless tasks.empty?
    redirect_to root_path(filters: filters)
  end

  def edit
    @subtitle = "Edit Task"
    @task = params[:task]
  end

  def update
    old_task = params[:task].strip
    new_task = params[:new_task].strip
    Delta.create!(type: Delta::UPDATE, arguments: [old_task, new_task])
    redirect_to root_path(filters: filters)
  end

  def destroy
    Delta.create!(type: Delta::DELETE, arguments: [params[:task]])
    redirect_back fallback_location: root_path
  end

  def complete
    Delta.create!(type: Delta::COMPLETE, arguments: [params[:task]])
    redirect_back fallback_location: root_path
  end

  def schedule
    Delta.create!(type: Delta::SCHEDULE, arguments: [params[:task]])
    redirect_back fallback_location: root_path
  end

  def unschedule
    Delta.create!(type: Delta::UNSCHEDULE, arguments: [params[:task]])
    redirect_back fallback_location: root_path
  end

  private

  def todo_repo
    @_todo_repo ||= TodoRepo.new(Figaro.env.TODO_FILE!)
  end

  def tasks_to_show
    to_show = todo_repo.incomplete_tasks

    filters.each do |filter|
      if filter.start_with?("+")
        to_show = to_show.select { |t| t.projects.include?(filter) }
      elsif filter.start_with?("@")
        to_show = to_show.select { |t| t.contexts.include?(filter) }
      end
    end

    TaskDecorator.decorate_collection(to_show)
  end

  def filters
    @filters ||= Array.wrap(params[:filters])
  end
  alias assign_filters filters

  def assign_tags
    @projects = todo_repo.all_projects
    @contexts = todo_repo.all_contexts
  end
end
