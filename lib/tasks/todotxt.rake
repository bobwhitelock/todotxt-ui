namespace :todotxt do
  namespace :cron do
    desc "Automatically clear today list and bump `scheduled` tracking"
    task clear_today_list: :environment do
      RakeLogger.info "starting"

      repo = TodoRepo.new(Figaro.env.TODO_FILE!)
      repo.reset_to_origin

      cleared_tasks = 0
      repo.incomplete_tasks
        .select(&:today?)
        .map do |task|
        task.unschedule(update_scheduled_tag: true)
        cleared_tasks += 1
      end

      repo.commit_todo_file("Automatically clear today list") && repo.push

      RakeLogger.info "#{cleared_tasks} tasks cleared"
    end

    desc "Attempt to sync unapplied local Deltas to remote repo"
    task sync_deltas: :environment do
      repo = TodoRepo.new(Figaro.env.TODO_FILE!)
      deltas = Delta.pending

      begin
        repo.reset_to_origin
        DeltaApplier.apply(deltas: deltas, todo_repo: repo)
        repo.push
        RakeLogger.info "#{deltas.length} deltas applied" unless deltas.empty?
      rescue Git::GitExecuteError => e
        RakeLogger.warn "Git error in `sync_deltas`, resetting all Deltas: #{e}"
        deltas.update(status: Delta::UNAPPLIED)
        repo.reset_to_origin
      end
    end
  end
end
