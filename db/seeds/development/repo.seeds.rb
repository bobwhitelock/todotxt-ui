TODO_REPO = Rails.root.join("tmp/todo_repo")

TASK_TO_BE_DELETED = "task to be deleted"
TASK_TO_BE_COMPLETED = "task to be completed"
TASK_TO_BE_SCHEDULED = "task to be scheduled"
TASK_TO_BE_UNSCHEDULED = "task to be unscheduled @today"

def system!(*args)
  Kernel.system(*args, exception: true)
end

def in_todo_repo(command)
  system! "cd #{TODO_REPO} && #{command}"
end

seed_tasks = [
  "2021-03-22 simple task 1",
  "2021-03-23 simple task 2",
  "2021-03-24 simple task 3",
  "2021-03-25 task with some tags +todotxt-ui @work @code @home key:value",
  "2021-03-26 another task with some tags @work @code key:value2",
  "2021-03-27 short",
  "2021-03-28 very long context @pneumonoultramicroscopicsilicovolcanoconiosis",
  "2021-03-29 very long project +pneumonoultramicroscopicsilicovolcanoconiosis",
  "2021-03-30 very long metadata disease:pneumonoultramicroscopicsilicovolcanoconiosis",
  "2021-03-31 task with a due date due:2021-08-13",
  "2021-04-01 another task with a due date due:2021-08-11",
  "2021-04-02 task that has previously been scheduled scheduled:3",
  "2021-04-03 task from yesterday @yesterday scheduled:1",
  "2021-04-04 task for today @today",
  "2021-04-05 task for tomorrow @tomorrow",
  "2021-04-06 task for Monday @monday",
  "2021-04-07 task with URL: https://github.com/bobwhitelock/todotxt-ui",
  "2021-04-08 task with backticks `@work` `+todotxt-ui`",
  "x 2021-04-13 2021-04-09 complete task",
  "(A) 2021-04-10 highest priority task",
  "(B) 2021-04-11 high priority task",
  "(C) 2021-04-12 lower priority task",
  "(Z) 2021-04-13 lowest priority task",
  "task without date",
  TASK_TO_BE_DELETED,
  TASK_TO_BE_COMPLETED,
  TASK_TO_BE_SCHEDULED,
  TASK_TO_BE_UNSCHEDULED,
  <<~TODOTXT.squish
    2021-04-14 a very long task that takes up lots of space -

    In a hole in the ground there lived a hobbit. Not a nasty, dirty, wet hole,
    filled with the ends of worms and an oozy smell, nor yet a dry, bare, sandy
    hole with nothing in it to sit down on or to eat: it was a hobbit-hole, and
    that means comfort.

    It had a perfectly round door like a porthole, painted green, with a shiny
    yellow brass knob in the exact middle. The door opened on to a tube-shaped
    hall like a tunnel: a very comfortable tunnel without smoke, with panelled
    walls, and floors tiled and carpeted, provided with polished chairs, and lots
    and lots of pegs for hats and coats - the hobbit was fond of visitors.
  TODOTXT
]

# Recreate repo.
TODO_REPO.rmtree
TODO_REPO.mkpath
in_todo_repo "git init"
begin
  in_todo_repo "git checkout master"
rescue
  in_todo_repo "git checkout -b master"
end
in_todo_repo "git remote add origin git@github.com:bobwhitelock/todotxt-ui_test-repo.git"

# Create todo file.
#
# Also set as the `TODO_FILE` to use in development in
# `config/application.yml`.
todo_file = TODO_REPO.join("todo.txt").to_s
todo_file_content = seed_tasks.join("\n") + "\n"
IO.write(todo_file, todo_file_content)
in_todo_repo "git add ."
in_todo_repo "git commit -m 'Initial commit'"
in_todo_repo "git push --force"
