after "development:repo" do
  new_task = "a new task"
  today = Date.today.to_s
  applied_new_task = "#{today} #{new_task}"

  seed_deltas = [
    {type: Delta::ADD, arguments: {task: new_task}},
    {type: Delta::UPDATE, arguments: {
      task: applied_new_task, new_task: "#{applied_new_task} - now updated"
    }},
    {type: Delta::DELETE, arguments: {task: TASK_TO_BE_DELETED}},
    {type: Delta::COMPLETE, arguments: {task: TASK_TO_BE_COMPLETED}},
    {type: Delta::SCHEDULE, arguments: {task: TASK_TO_BE_SCHEDULED}},
    {type: Delta::UNSCHEDULE, arguments: {task: TASK_TO_BE_UNSCHEDULED}}
  ]

  seed_deltas.each do |args|
    Delta.create!(args)
  end
end
