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
    UNAPPLIED,
    APPLIED,
    INVALID,
  ]

  validates :type, presence: true, inclusion: { in: TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates_presence_of(:arguments)

  scope :pending, -> { where(status: UNAPPLIED).order('created_at') }
end
