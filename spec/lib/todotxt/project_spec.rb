require "rails_helper"

RSpec.describe Todotxt::Project do
  describe ".new" do
    it "raises when given invalid project" do
      expect {
        described_class.new("not_a_project")
      }.to raise_error(
        Todotxt::UsageError, "Not a valid project: `not_a_project`"
      )
    end
  end
end
