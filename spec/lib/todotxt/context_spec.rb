require "rails_helper"

RSpec.describe Todotxt::Context do
  describe "#to_s" do
    it "gives context in todotxt format" do
      expect(described_class.new("@foo").to_s).to eq("@foo")
    end
  end
end
