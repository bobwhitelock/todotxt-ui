require "spec_helper"

RSpec.describe Todotxt::Config do
  describe "#to_s and #inspect" do
    it "returns useful representation of Config" do
      config = described_class.new(parse_code_blocks: true)

      expected_result = \
        "<Todotxt::Config: parse_code_blocks=true task_class=Todotxt::Task>"
      expect(config.to_s).to eq(expected_result)
      expect(config.inspect).to eq(expected_result)
    end
  end
end
