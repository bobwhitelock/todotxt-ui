class Delta < ApplicationRecord
  # Types.
  ADD = "add"
  UPDATE = "update"
  DELETE = "delete"
  COMPLETE = "complete"
  SCHEDULE = "schedule"
  UNSCHEDULE = "unschedule"

  # Argument names.
  TASK = "task"
  NEW_TASK = "new_task"
  FILE = "file"

  ARGUMENT_DEFINITIONS = {
    ADD => [TASK, FILE],
    UPDATE => [TASK, NEW_TASK, FILE],
    DELETE => [TASK, FILE],
    COMPLETE => [TASK, FILE],
    SCHEDULE => [TASK, FILE],
    UNSCHEDULE => [TASK, FILE]
  }

  TYPES = ARGUMENT_DEFINITIONS.keys

  UNAPPLIED = "unapplied"
  APPLIED = "applied"
  STATUSES = [
    # Unapplied = Delta's change has not yet been committed.
    UNAPPLIED,
    # Applied = Delta's change has been committed, or it has been checked by
    # DeltaApplier and has no change requiring it to be committed (e.g. if 2
    # identical updates were made near simultaneously).
    APPLIED
  ]

  validates_presence_of :type
  validates :type, inclusion: {in: TYPES}
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates_presence_of(:arguments)
  validate :validate_arguments

  scope :pending, -> { where(status: UNAPPLIED).order("created_at") }

  STATUSES.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  def task
    arguments.fetch("task")
  end

  def new_task
    arguments.fetch("new_task")
  end

  def file
    arguments.fetch("file")
  end

  private

  delegate :valid_arguments_length, to: :type_config

  def validate_arguments
    return unless arguments

    if arguments.keys != expected_arguments
      expected_args_string = expected_arguments.map { |arg| "'#{arg}'" }.join(", ")
      message = "This type of Delta expects these arguments: #{expected_args_string}"
      errors.add(:arguments, message)
    end
  end

  def expected_arguments
    ARGUMENT_DEFINITIONS[type]
  end
end
