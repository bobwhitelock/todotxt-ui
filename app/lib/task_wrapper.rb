class TaskWrapper < Todotxt::Task
  def equals_raw_task(raw_task)
    raw == raw_task.strip
  end

  def schedule
    self.contexts += [Context::TODAY]
  end

  def unschedule
    self.contexts -= [Context::TODAY]
  end

  def to_json
    {
      raw: raw,
      descriptionText: description_text,
      complete: complete?,
      priority: priority,
      creationDate: creation_date&.iso8601,
      completionDate: completion_date&.iso8601,
      contexts: contexts,
      projects: projects,
      metadata: metadata.map do |k, v|
        [k, v.respond_to?(:iso8601) ? v.iso8601 : v]
      end.to_h
    }
  end
end
