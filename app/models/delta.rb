class Delta < ApplicationRecord
  ADD = 'add'
  UPDATE = 'update'
  DELETE = 'delete'
  COMPLETE = 'complete'
  SCHEDULE = 'schedule'
  UNSCHEDULE = 'unschedule'
  TYPES = [
    ADD,
    UPDATE,
    DELETE,
    COMPLETE,
    SCHEDULE,
    UNSCHEDULE,
  ]

  UNAPPLIED = 'unapplied'
  APPLIED = 'applied'
  INVALID = 'invalid'
  STATUSES = [
    # Unapplied = Delta's change has not yet been committed.
    UNAPPLIED,
    # Applied = Delta's change has been committed, or it has been checked by
    # DeltaApplier and has no change requiring it to be committed (e.g. if 2
    # identical updates were made near simultaneously).
    APPLIED,
    # Invalid = Delta is of an unknown type and so cannot be handled; maybe
    # other reasons in future.
    INVALID,
  ]

  validates_presence_of :type
  validates :type, inclusion: { in: TYPES }, unless: :invalid?
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates_presence_of(:arguments)

  scope :pending, -> { where(status: UNAPPLIED).order('created_at') }

  STATUSES.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end
end
