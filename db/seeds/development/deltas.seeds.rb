after "development:repo" do
  new_task = "a new task"
  today = Date.today.to_s
  applied_new_task = "#{today} #{new_task}"

  seed_deltas = [
    {type: Delta::ADD, arguments: [new_task]},
    {type: Delta::UPDATE, arguments: [applied_new_task, "#{applied_new_task} - now updated"]},
    {type: Delta::DELETE, arguments: [TASK_TO_BE_DELETED]},
    {type: Delta::COMPLETE, arguments: [TASK_TO_BE_COMPLETED]},
    {type: Delta::SCHEDULE, arguments: [TASK_TO_BE_SCHEDULED]},
    {type: Delta::UNSCHEDULE, arguments: [TASK_TO_BE_UNSCHEDULED]}
  ]

  seed_deltas.each do |args|
    Delta.create!(args)
  end
end
