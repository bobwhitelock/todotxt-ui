class TasksController < ApplicationController
  before_action :assign_filters, :assign_tags

  def index
    # XXX Don't do this on every request to avoid blocking rendering page.
    pull_and_reset

    @total_tasks = tasks.by_not_done.length
    @tasks = tasks_to_show.sort_by do |task|
      [
        task.today? ? 'a' : 'b',
        # XXX Only show things due soon first?
        task.tags.fetch(:due, 'z'),
        task.priority || 'Z',
        task.created_on || 100.years.from_now,
        task.raw
      ]
    end
    @subtitle = "#{@tasks.size} tasks"
  end

  def new
    @subtitle = 'Add Tasks'
  end

  def create
    tasks = params[:tasks].strip
    Delta.create!(type: Delta::ADD, arguments: [tasks]) unless tasks.empty?
    redirect_to root_path(filters: filters)
  end

  def edit
    @subtitle = 'Edit Task'
    @task = params[:task]
  end

  def update
    old_task = params[:task].strip
    new_task = params[:tasks].strip
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

  delegate :tasks, to: :todo_repo

  def todo_repo
    @_todo_repo ||= TodoRepo.new(ENV.fetch('TODO_FILE'))
  end

  def tasks_to_show
    to_show = tasks.by_not_done

    filters.each do |filter|
      if filter.start_with?('+')
        to_show = to_show.by_project(filter)
      elsif filter.start_with?('@')
        to_show = to_show.by_context(filter)
      end
    end

    TaskDecorator.decorate_collection(to_show)
  end

  def filters
    @filters ||= Array.wrap(params[:filters])
  end
  alias_method :assign_filters, :filters

  def assign_tags
    @projects = todo_repo.all_projects
    @contexts = todo_repo.all_contexts
  end
end
