require "spec_helper"

RSpec.describe Todotxt::Metadatum do
  describe ".new" do
    it "sets value to string given unconvertible string" do
      metadatum = described_class.new("foo", "bar")

      expect(metadatum.value).to eq("bar")
    end

    it "sets value to integer if it can be converted to an integer" do
      metadatum = described_class.new("foo", "5")

      expect(metadatum.value).to eq(5)
    end

    it "sets value to string if it can be converted to a float" do
      metadatum = described_class.new("foo", "3.14")

      # Do not want to convert values which look like floats to floats by
      # default, as every such string cannot be converted to a float and back
      # losslessly, and so this would risk losing useful information when
      # round-tripping a Task.
      expect(metadatum.value).to eq("3.14")
    end

    it "sets value to date given date" do
      date = Date.new(2038, 2, 1)
      metadatum = described_class.new("due", date)

      expect(metadatum.value).to eq(date)
    end
  end

  describe "#to_s" do
    it "converts metadatum to todotxt format when has string value" do
      expect(
        described_class.new("foo", "bar").to_s
      ).to eq("foo:bar")
    end

    it "converts metadatum to todotxt format when has integer value" do
      expect(
        described_class.new("foo", 5).to_s
      ).to eq("foo:5")
    end

    it "converts metadatum to todotxt format when has date value" do
      date = Date.new(2038, 2, 1)

      expect(
        described_class.new("foo", date).to_s
      ).to eq("foo:2038-02-01")
    end
  end
end
