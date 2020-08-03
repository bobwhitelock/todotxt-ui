class Todotxt
  class Project
    attr_reader :value
    alias to_s value

    def initialize(value)
      @value = value
    end

    def ==(other_project)
      other_project.is_a?(Project) && other_project.value == value
    end
  end
end
