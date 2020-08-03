require "rails_helper"

RSpec.describe Todotxt::Task do
  describe ".parse" do
    it "parses a simple todotxt task into a Task" do
      raw_task = "do things @home"

      task = described_class.parse(raw_task)

      expect(task).not_to be_complete
      expect(task.priority).to be nil
      expect(task.completion_date).to be nil
      expect(task.creation_date).to be nil
      expect(task.description).to eq("do things @home")
      expect(task.description_text).to eq("do things")
      expect(task.contexts).to eq([Todotxt::Context.new("@home")])
      expect(task.projects).to eq([])
      expect(task.tags).to eq([])
      expect(task.raw).to eq(raw_task)
    end

    it "parses a complex todotxt task into a Task" do
      raw_task = "x (B) 2020-08-02 2019-07-01 do things @home and other stuff +important +housework due:2020-08-09"

      task = described_class.parse(raw_task)

      expect(task).to be_complete
      expect(task.priority).to eq("B")
      expect(task.completion_date).to eq(Date.new(2020, 8, 2))
      expect(task.creation_date).to eq(Date.new(2019, 7, 1))
      expect(task.description).to eq(
        "do things @home and other stuff +important +housework due:2020-08-09"
      )
      expect(task.description_text).to eq("do things and other stuff")
      expect(task.contexts).to eq([Todotxt::Context.new("@home")])
      expect(task.projects).to eq([
        Todotxt::Project.new("+important"), Todotxt::Project.new("+housework")
      ])
      expect(task.tags).to eq([
        Todotxt::Tag.new(key: "due", value: "2020-08-09")
      ])
      expect(task.raw).to eq(raw_task)
    end
  end

  describe ".new" do
    it "is private" do
      expect(described_class).not_to respond_to(:new)
    end
  end
end
