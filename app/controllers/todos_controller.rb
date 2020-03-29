class TodosController < ApplicationController
  def index
    @todos = todos.by_not_done.sort_by do |todo|
      [
        # XXX Only show things due soon first?
        todo.tags.fetch(:due, 'z'),
        todo.priority || 'Z',
        todo.created_on
      ]
    end
  end

  def destroy
    find_todo_and do |todo|
      todos.delete_if do |t|
        t.raw == todo.raw
      end
    end
  end

  def complete
    find_todo_and(&:do!)
  end

  private

  def todos
    @_todos ||= Todo::List.new(todo_file)
  end

  def todo_file
    @_todo_file ||= ENV.fetch('TODO_FILE')
  end

  def find_todo_and
    raw_todo = params[:todo]
    todo_to_operate_on = todos.find do |todo|
      todo.raw.strip == raw_todo
    end

    # XXX Flash a message in the else case, something has gone wrong
    if todo_to_operate_on
      yield todo_to_operate_on
      todos.save!
    end

    redirect_back fallback_location: root_path
  end
end
