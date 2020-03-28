class TodosController < ApplicationController
  def index
    todo_file = ENV.fetch('TODO_FILE')
    @todos = Todo::List.new todo_file
  end
end
