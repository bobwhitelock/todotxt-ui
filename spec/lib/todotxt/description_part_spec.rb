require "rails_helper"

class TestDescriptionPart < Todotxt::DescriptionPart; end

class OtherTestDescriptionPart < Todotxt::DescriptionPart; end

RSpec.describe Todotxt::DescriptionPart do
  describe "#==" do
    subject { TestDescriptionPart.new("foo") }

    it "returns true if other part has the same class and value" do
      other_part = TestDescriptionPart.new("foo")

      expect(subject == other_part).to be true
    end

    it "returns false if other part has different class" do
      other_part = OtherTestDescriptionPart.new("foo")

      expect(subject == other_part).to be false
    end

    it "returns false if other part has different value" do
      other_part = TestDescriptionPart.new("bar")

      expect(subject == other_part).to be false
    end
  end

  describe "#to_s" do
    it "returns wrapped value" do
      expect(described_class.new("foo").to_s).to eq("foo")
    end
  end
end
