class Todotxt
  class TodotxtError < StandardError; end

  class InternalError < TodotxtError; end

  class UsageError < TodotxtError; end

  # XXX Delete this once no longer defining Todotxt code within Rails app (but
  # required for this to work until then).
  class Exceptions; end
end
