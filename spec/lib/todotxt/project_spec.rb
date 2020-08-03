require "rails_helper"

RSpec.describe Todotxt::Project do
  describe "#to_s" do
    it "gives project in todotxt format" do
      expect(described_class.new("+foo").to_s).to eq("+foo")
    end
  end
end
