class Delta < ApplicationRecord
  class TypeConfig
    attr_reader :valid_arguments_length

    def initialize(valid_arguments_length: 1)
      @valid_arguments_length = valid_arguments_length
    end
  end

  ADD = "add"
  UPDATE = "update"
  DELETE = "delete"
  COMPLETE = "complete"
  SCHEDULE = "schedule"
  UNSCHEDULE = "unschedule"

  TYPE_CONFIGS = {
    ADD => {},
    UPDATE => {valid_arguments_length: 2},
    DELETE => {},
    COMPLETE => {},
    SCHEDULE => {},
    UNSCHEDULE => {}
  }.transform_values { |c| TypeConfig.new(**c) }

  TYPES = TYPE_CONFIGS.keys

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
  validate :validate_correct_number_of_arguments

  scope :pending, -> { where(status: UNAPPLIED).order("created_at") }

  STATUSES.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  private

  delegate :valid_arguments_length, to: :type_config

  def validate_correct_number_of_arguments
    return unless arguments

    if arguments.length != valid_arguments_length
      argument_or_arguments = "argument".pluralize(valid_arguments_length)
      message = "This type of Delta expects #{valid_arguments_length} #{argument_or_arguments}"
      errors.add(:arguments, message)
    end
  end

  def type_config
    TYPE_CONFIGS[type]
  end
end
