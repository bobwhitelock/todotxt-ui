namespace :todotxt do
  namespace :cron do
    desc "Progress scheduled tasks through available states; intended to be run daily, early in the day"
    task progress_scheduled_tasks: :environment do
      RakeLogger.info "starting"
      repo = TodoRepo.new(Figaro.env.TODO_FILE!)

      attempt = 1
      retry_config = {
        # Set high number of tries, so will retry for an hour rather than a set
        # number of attempts.
        tries: 1000,
        on: Git::GitExecuteError,
        base_interval: 10.seconds,
        max_elapsed_time: 1.hour,
        on_retry: proc do |error|
          RakeLogger.warn "Git error in `progress_scheduled_tasks`, will retry (attempt #{attempt}): #{error}"
          attempt += 1
        end
      }

      Retriable.retriable(**retry_config) do
        repo.reset_to_origin
        DailyScheduler.progress(todo_repo: repo)
      end
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
