require "rails_helper"

RSpec.describe TaskWrapper do
  # XXX Move this in to main Task class instead (if yes, maybe include
  # `description` too)?
  describe "#to_json" do
    it "returns key properties of Task as a hash" do
      raw_task = "x (B) 2021-04-06 2021-04-05 some task @context +proj1 +proj2 due:2021-07-07 str:foo int:5"
      task = described_class.new(raw_task)

      expect(task.to_json).to eq({
        raw: raw_task,
        description_text: "some task",
        complete: true,
        priority: "B",
        creation_date: "2021-04-05",
        completion_date: "2021-04-06",
        contexts: ["@context"],
        projects: ["+proj1", "+proj2"],
        metadata: {
          due: "2021-07-07",
          str: "foo",
          int: 5
        }
      })
    end
  end
end
