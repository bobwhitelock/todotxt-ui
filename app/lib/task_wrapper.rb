class TaskWrapper < Todotxt::Task
  def equals_raw_task(raw_task)
    raw == raw_task.strip
  end

  def today?
    contexts.include?(Context::TODAY)
  end

  def schedule
    self.contexts += [Context::TODAY]
  end

  def unschedule
    self.contexts -= [Context::TODAY]
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

  def to_json
    {
      raw: raw,
      description_text: description_text,
      complete: complete?,
      priority: priority,
      creation_date: creation_date&.iso8601,
      completion_date: completion_date&.iso8601,
      contexts: contexts,
      projects: projects,
      metadata: metadata.map do |k, v|
        [k, v.respond_to?(:iso8601) ? v.iso8601 : v]
      end.to_h
    }
  end
end
