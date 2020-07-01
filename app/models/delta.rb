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

  validates :type, presence: true, inclusion: { in: TYPES }
  validates_presence_of(:arguments)

  scope :pending, -> { where(applied: false).order('created_at') }
end
