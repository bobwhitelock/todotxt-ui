namespace :todotxt do
  namespace :cron do
    desc "Progress scheduled tasks through available states; intended to be run daily, early in the day"
    task progress_scheduled_tasks: :environment do
      RakeLogger.info "starting"
      repo = TodoRepo.new(Figaro.env.TODO_FILE!)
      repo.reset_to_origin
      DailyScheduler.progress(todo_repo: repo)
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
