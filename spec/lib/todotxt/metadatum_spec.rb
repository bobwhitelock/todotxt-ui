require "rails_helper"

RSpec.describe Todotxt::Metadatum do
  describe "#to_s" do
    it "gives metadatum in todotxt format" do
      expect(
        described_class.new("foo", "bar").to_s
      ).to eq("foo:bar")
    end
  end
end
