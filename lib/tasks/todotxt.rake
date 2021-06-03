require "timeout"

LOCK_FILE = "todotxt-ui.lock"

namespace :todotxt do
  namespace :cron do
    desc "Progress scheduled tasks through available states; intended to be run daily, early in the day"
    task progress_scheduled_tasks: :environment do
      RakeLogger.info "Starting"

      lock_file = File.new(LOCK_FILE, File::CREAT | File::RDWR, 0o644)
      Timeout.timeout(60 * 5) do
        lock_file.flock(File::LOCK_EX) # Get exclusive, blocking lock.
      end
      RakeLogger.info "Obtained lock"

      begin
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
      ensure
        lock_file.flock(File::LOCK_UN)
        RakeLogger.info "Released lock"
      end
    end

    desc "Attempt to sync unapplied local Deltas to remote repo"
    task sync_deltas: :environment do
      deltas = Delta.pending
      # Only log (apart from logging errors) if any Deltas found, to avoid
      # verbose and unhelpful logs.
      should_log = deltas.any?
      deltas_count = deltas.length
      RakeLogger.info "Found #{deltas_count} unapplied Deltas" if should_log

      lock_file = File.new(LOCK_FILE, File::CREAT | File::RDWR, 0o644)
      lock_file.flock(File::LOCK_EX | File::LOCK_NB) # Get exclusive, non-blocking lock.
      RakeLogger.info "Obtained lock" if should_log

      repo = TodoRepo.new(Figaro.env.TODO_FILE!)

      begin
        repo.reset_to_origin
        DeltaApplier.apply(deltas: deltas, todo_repo: repo)
        repo.push
        RakeLogger.info "#{deltas_count} deltas applied" if should_log
      rescue Git::GitExecuteError => e
        RakeLogger.warn "Git error in `sync_deltas`, resetting all Deltas: #{e}"
        deltas.update(status: Delta::UNAPPLIED)
        repo.reset_to_origin
      ensure
        lock_file.flock(File::LOCK_UN)
        RakeLogger.info "Released lock" if should_log
      end
    end
  end
end
