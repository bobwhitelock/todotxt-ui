class TodosController < ApplicationController
  def index
    todo_file = ENV.fetch('TODO_FILE')
    @todos = Todo::List.new(todo_file).sort_by do |todo|
      [
        # XXX Only show things due soon first?
        todo.tags.fetch(:due, 'z'),
        todo.priority || 'Z',
        todo.created_on
      ]
    end
  end
end
