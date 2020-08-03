require "rails_helper"

RSpec.describe Todotxt::Text do
  describe "#to_s" do
    it "gives wrapped text" do
      expect(described_class.new("foo bar").to_s).to eq("foo bar")
    end
  end
end
