require "rails_helper"

RSpec.describe Todotxt::Metadatum do
  describe "#to_s" do
    it "gives metadatum in todotxt format" do
      expect(
        described_class.new(key: "foo", value: "bar").to_s
      ).to eq("foo:bar")
    end
  end
end
