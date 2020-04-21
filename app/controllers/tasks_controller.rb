class TasksController < ApplicationController
  def index
    # XXX Don't do this on every request to avoid blocking rendering page.
    todo_repo.pull_and_reset

    @filters = filters
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
    today = Time.now.strftime('%F')

    new_tasks = params[:tasks].lines.map(&:strip).reject(&:empty?)
    new_tasks.each do |task|
      task_with_timestamp = "#{today} #{task}"
      tasks << task_with_timestamp
    end

    todo_repo.save_and_push unless new_tasks.empty?
    redirect_to root_path
  end

  def edit
    @subtitle = 'Edit Task'
    @task = params[:task]
  end

  def update
    find_task_and do |task|
      delete_matching_task(task)
      tasks << params[:new_task]
    end
    redirect_to root_path
  end

  def destroy
    find_task_and do |task|
      delete_matching_task(task)
    end
    redirect_back fallback_location: root_path
  end

  def complete
    find_task_and(&:do!)
    redirect_back fallback_location: root_path
  end

  def schedule
    find_task_and do |task|
      delete_matching_task(task)
      tasks << task.raw.strip + ' @today'
    end
    redirect_back fallback_location: root_path
  end

  def unschedule
    find_task_and do |task|
      delete_matching_task(task)
      tasks << task.raw.gsub(/\s+@today\s+/, ' ').strip
    end
    redirect_back fallback_location: root_path
  end

  private

  delegate :tasks, to: :todo_repo

  def todo_repo
    @_todo_repo ||= TodoRepo.new
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
    Array.wrap(params[:filters])
  end

  def find_task_and
    raw_task = params[:task]
    task_to_operate_on = tasks.find do |task|
      task.raw.strip == raw_task
    end

    # XXX Flash a message in the else case, something has gone wrong
    if task_to_operate_on
      yield task_to_operate_on
      todo_repo.save_and_push
    end
  end

  def delete_matching_task(task)
    tasks.delete_if do |t|
      t.raw == task.raw
    end
  end
end
