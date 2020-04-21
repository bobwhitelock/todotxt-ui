
# Seemingly allows Draper to work without using ActiveRecord.
class ActiveRecord
  class Relation
    VALUE_METHODS = []
  end
end
