require "rails_helper"

RSpec.describe Todotxt::Context do
  describe ".new" do
    it "raises when given invalid context" do
      expect {
        described_class.new("not_a_context")
      }.to raise_error(
        Todotxt::UsageError, "Not a valid context: `not_a_context`"
      )
    end
  end
end
