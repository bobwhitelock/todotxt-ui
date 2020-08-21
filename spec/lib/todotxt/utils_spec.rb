require "rails_helper"

RSpec.describe Todotxt::Utils do
  describe ".delete_first" do
    it "raises when neither `item` nor block passed" do
      expect {
        described_class.delete_first([])
      }.to raise_error(Todotxt::InternalError)
    end

    it "raises when both `item` and block passed" do
      expect {
        described_class.delete_first([], "foo") { |item| item }
      }.to raise_error(Todotxt::InternalError)
    end

    context "when `item` passed" do
      it "deletes and returns first matching item in array" do
        array = ["foo", "bar", "foo", "bar"]

        result = described_class.delete_first(array, "bar")

        expect(array).to eq(["foo", "foo", "bar"])
        expect(result).to eq("bar")
      end

      it "deletes nothing when no matching item in array" do
        array = ["foo", "foo"]

        result = described_class.delete_first(array, "bar")

        expect(array).to eq(["foo", "foo"])
        expect(result).to be nil
      end
    end

    context "when block passed" do
      it "deletes and returns first item block evaluates as true for" do
        array = ["foo", "bar", "foo", "bar"]

        result = described_class.delete_first(array) { |item| item[0] == "b" }

        expect(array).to eq(["foo", "foo", "bar"])
        expect(result).to eq("bar")
      end

      it "deletes nothing when block does not evaluate as true for any item" do
        array = ["foo", "foo"]

        result = described_class.delete_first(array) { |item| item[0] == "b" }

        expect(array).to eq(["foo", "foo"])
        expect(result).to be nil
      end
    end
  end
end
