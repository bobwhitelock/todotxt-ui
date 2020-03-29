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

  def complete
    raw_todo_to_complete = params[:todo]
    todo_to_complete = todos.find do |todo|
      todo.raw.strip == raw_todo_to_complete
    end

    # XXX Flash a message in the else case, something has gone wrong
    if todo_to_complete
      todo_to_complete.do!
      Todo::File.write(todo_file, todos)
    end

    redirect_to root_path
  end

  private

  def todos
    @_todos ||= Todo::List.new(todo_file)
  end

  def todo_file
    @_todo_file ||= ENV.fetch('TODO_FILE')
  end
end
