SimpleCov.start 'rails' do
  # Track branch as well as line coverage.
  enable_coverage :branch

  # Track and group coverage of all Rake tasks (not working?).
  add_group 'Rake tasks', 'lib/tasks'
  track_files 'lib/tasks/**/*.rake'

  # Track and group coverage of decorators.
  add_group 'Decorators', 'app/decorators'
  track_files 'app/decorators/**/*.rb'
end
