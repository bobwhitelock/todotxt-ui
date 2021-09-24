after "development:repo" do
  new_task = "a new task"
  today = Date.today.to_s
  applied_new_task = "#{today} #{new_task}"

  seed_deltas = [
    {
      type: Delta::ADD,
      arguments: {task: new_task, file: TODO_FILE}
    },
    {
      type: Delta::UPDATE,
      arguments: {
        task: applied_new_task,
        new_task: "#{applied_new_task} - now updated",
        file: TODO_FILE
      }
    },
    {
      type: Delta::DELETE,
      arguments: {task: TASK_TO_BE_DELETED, file: TODO_FILE}
    },
    {
      type: Delta::COMPLETE,
      arguments: {task: TASK_TO_BE_COMPLETED, file: TODO_FILE}
    },
    {
      type: Delta::SCHEDULE,
      arguments: {task: TASK_TO_BE_SCHEDULED, file: TODO_FILE}
    },
    {
      type: Delta::UNSCHEDULE,
      arguments: {task: TASK_TO_BE_UNSCHEDULED, file: TODO_FILE}
    },
    {
      type: Delta::ADD,
      arguments: {task: "task for backlog", file: BACKLOG_FILE}
    }
  ]

  seed_deltas.each do |args|
    Delta.create!(args)
  end
end
