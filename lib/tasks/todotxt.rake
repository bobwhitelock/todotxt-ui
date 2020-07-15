
namespace :todotxt do
  namespace :cron do
    # XXX Make this nicer and DRY up with `TasksController`.
    desc 'Automatically clear today list and bump `scheduled` tracking'
    task clear_today_list: :environment do
      repo = TodoRepo.new(ENV.fetch('TODO_FILE'))
      repo.pull_and_reset
      tasks = repo.tasks

      updates = {}
      tasks.by_not_done.each do |task|
        task = TaskDecorator.new(task)

        if task.today?
          scheduled = task.tags.fetch(:scheduled, 0).to_i

          new_task = task
            .raw
            .gsub(/\s*@today\s*/, ' ')
            .gsub(/\s*scheduled:#{scheduled}\s*/, ' ')
            .strip
          new_task += " scheduled:#{scheduled + 1}"

          updates[task.raw] = new_task
        end
      end

      updates.each do |raw_task, new_task|
        tasks.delete_if do |t|
          t.respond_to?(:raw) && t.raw == raw_task
        end
        tasks << new_task
      end

      unless updates.empty?
        repo.save_and_push('Automatically clear today list')
      end
    end

    desc 'Attempt to pull and then sync unapplied local Deltas to remote repo'
    task sync_deltas: :environment do
      repo = TodoRepo.new(ENV.fetch('TODO_FILE'))
      deltas = Delta.pending

      begin
        repo.pull
        DeltaApplier.apply(deltas: deltas, todo_repo: repo)
        repo.push
      rescue Git::GitExecuteError
        deltas.update(status: Delta::UNAPPLIED)
        repo.reset_to_origin
      end
    end
  end
end
