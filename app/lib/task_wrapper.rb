class TaskWrapper < Todotxt::Task
  def equals_raw_task(raw_task)
    raw == raw_task.strip
  end

  def today?
    contexts.include?("@today")
  end

  def schedule
    self.contexts += ["@today"]
  end

  def unschedule(update_scheduled_tag: false)
    self.contexts -= ["@today"]

    if update_scheduled_tag
      scheduled = metadata.fetch(:scheduled, 0).to_i
      self.metadata = {**metadata, scheduled: scheduled + 1}
    end
  end

  def ui_sort_key
    # Each entry in this array should always be comparable for every task,
    # otherwise sorting using this can blow up.
    [
      today? ? "a" : "b",
      # Compare `due` metadata values as strings, since there is no guarantee
      # that only Dates will be used for these.
      metadata.fetch(:due, "zzz").to_s,
      priority || "Z",
      creation_date || 100.years.from_now,
      raw
    ]
  end
end
