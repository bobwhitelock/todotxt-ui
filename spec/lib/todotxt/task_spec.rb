require "rails_helper"
require "support/todotxt_helpers"

RSpec.describe Todotxt::Task do
  it "is comparable" do
    task = create_task("foo")

    expect(task).to be_a(Comparable)
  end

  describe ".new" do
    it "parses a simple todotxt task into a Task" do
      raw_task = "do things @home"

      task = described_class.new(raw_task)

      expect(task).not_to be_complete
      expect(task.priority).to be nil
      expect(task.completion_date).to be nil
      expect(task.creation_date).to be nil
      expect(task.description).to eq("do things @home")
      expect(task.description_text).to eq("do things")
      expect(task.contexts).to eq(["@home"])
      expect(task.projects).to eq([])
      expect(task.tags).to eq({})
      expect(task.raw).to eq(raw_task)
    end

    it "parses a complex todotxt task into a Task" do
      raw_task = "x (B) 2020-08-02 2019-07-01 do things @home and other stuff +important +housework due:2020-08-09"

      task = described_class.new(raw_task)

      expect(task).to be_complete
      expect(task.priority).to eq("B")
      expect(task.completion_date).to eq(Date.new(2020, 8, 2))
      expect(task.creation_date).to eq(Date.new(2019, 7, 1))
      expect(task.description).to eq(
        "do things @home and other stuff +important +housework due:2020-08-09"
      )
      expect(task.description_text).to eq("do things and other stuff")
      expect(task.contexts).to eq(["@home"])
      expect(task.projects).to eq(["+important", "+housework"])
      expect(task.tags).to eq(due: "2020-08-09")
      expect(task.raw).to eq(raw_task)
    end

    it "exposes parsed text as strings" do
      raw_task = "(A) stuff @context +project tag_key:tag_value"

      task = described_class.new(raw_task)

      expect(task.priority).to be_a(String)
      expect(task.description).to be_a(String)
      expect(task.description_text).to be_a(String)
      expect(task.contexts.first).to be_a(String)
      expect(task.projects.first).to be_a(String)
      tag_key, tag_value = task.tags.first
      # Tag key is actually a Symbol as this is nicer to work with.
      expect(tag_key).to be_a(Symbol)
      expect(tag_value).to be_a(String)
    end

    it "trims any whitespace from passed raw task" do
      raw_task = "   a messy task  \n"

      task = described_class.new(raw_task)

      expect(task.raw).to eq("a messy task")
    end
  end

  describe "#<=>" do
    it "compares Tasks by their raw text" do
      task = create_task("bbb")
      earlier_task = create_task("aaa")
      later_task = create_task("ccc")
      equivalent_task = create_task("bbb")

      expect(task <=> earlier_task).to eq(1)
      expect(task <=> later_task).to eq(-1)
      expect(task <=> equivalent_task).to eq(0)
    end

    it "returns nil when compare with a non-Task" do
      task = create_task("my task")

      expect(task <=> 5).to be nil
    end
  end

  describe "#dirty?" do
    it "returns true if Task has been modified from original raw value loaded" do
      task = create_task("my task")
      task.contexts = ["@foo"]

      expect(task).to be_dirty
    end

    it "returns false if Task has not been modified" do
      task = create_task("my task")

      expect(task).not_to be_dirty
    end

    it "returns false if Task has been modified but retains same raw value" do
      task = create_task("my task")
      task.contexts = ["@foo"]
      task.contexts = []

      expect(task).not_to be_dirty
    end

    it "returns false for unmodified Task created with leading/trailing whitespace" do
      task = create_task("  my task   ")

      expect(task).not_to be_dirty
    end

    # XXX Implement this once saving is possible.
    it "returns false if Task has been modified and then saved"
  end

  describe "#reset" do
    it "resets Task to original raw value loaded" do
      task = create_task("my task")
      task.projects = ["+foo", "+bar"]
      task.priority = "C"

      task.reset

      expect(task.raw).to eq("my task")
    end
  end

  describe "#tags" do
    it "provides a hash of Task tag keys to values" do
      task = create_task("my task foo:bar baz:5")

      expect(task.tags).to eq(foo: "bar", baz: "5")
    end
  end

  describe "#complete=" do
    it "sets whether Task is complete" do
      allow(Date).to receive(:today).and_return(Date.new(2020, 8, 10))
      incomplete_task = create_task("my task")
      complete_task = create_task("x 2020-07-05 my complete task")

      incomplete_task.complete = true
      complete_task.complete = false

      expect(incomplete_task).to be_complete
      expect(incomplete_task.raw).to eq("x 2020-08-10 my task")
      expect(complete_task).not_to be_complete
      expect(complete_task.raw).to eq("my complete task")
    end
  end

  describe "#complete!" do
    before :each do
      allow(Date).to receive(:today).and_return(Date.new(2020, 8, 10))
    end

    it "sets incomplete Task to complete" do
      incomplete_task = create_task("my task")

      incomplete_task.complete!

      expect(incomplete_task).to be_complete
      expect(incomplete_task.raw).to eq("x 2020-08-10 my task")
    end

    it "leaves complete Task unchanged" do
      complete_task = create_task("x 2020-07-05 my complete task")

      complete_task.complete!

      expect(complete_task).to be_complete
      expect(complete_task.raw).to eq("x 2020-07-05 my complete task")
    end
  end

  describe "#priority=" do
    it "sets Task priority" do
      task = create_task("my task")

      task.priority = "B"

      expect(task.priority).to eq("B")
      expect(task.raw).to eq("(B) my task")
    end
  end

  describe "#increase_priority" do
    it "increases Task priority" do
      task = create_task("(C) my task")

      task.increase_priority

      expect(task.priority).to eq("B")
    end

    it "does not increase Task priority when already at maximum" do
      task = create_task("(A) my task")

      task.increase_priority

      expect(task.priority).to eq("A")
    end

    it "leaves Task without priority unchanged" do
      task = create_task("my task")

      task.increase_priority

      expect(task.priority).to be nil
      expect(task.raw).to eq("my task")
    end
  end

  describe "#decrease_priority" do
    it "decreases Task priority" do
      task = create_task("(C) my task")

      task.decrease_priority

      expect(task.priority).to eq("D")
    end

    it "does not decrease Task priority when already at minimum" do
      task = create_task("(Z) my task")

      task.decrease_priority

      expect(task.priority).to eq("Z")
    end

    it "leaves Task without priority unchanged" do
      task = create_task("my task")

      task.decrease_priority

      expect(task.priority).to be nil
      expect(task.raw).to eq("my task")
    end
  end

  describe "#completion_date=" do
    it "sets Task completion date" do
      task = create_task("x my task")

      task.completion_date = Date.new(2020, 8, 10)

      expect(task.completion_date).to eq(Date.new(2020, 8, 10))
      expect(task.raw).to eq("x 2020-08-10 my task")
    end
  end

  describe "#creation_date=" do
    it "sets Task creation date" do
      task = create_task("my task")

      task.creation_date = Date.new(2020, 8, 10)

      expect(task.creation_date).to eq(Date.new(2020, 8, 10))
      expect(task.raw).to eq("2020-08-10 my task")
    end
  end

  describe "#description=" do
    it "replaces current description with parsed new description" do
      task = create_task("(B) 2020-08-22 do some things @home")

      task.description = "do other things @work"

      expect(task.raw).to eq("(B) 2020-08-22 do other things @work")
      expect(task.description).to eq("do other things @work")
    end
  end

  describe "#contexts=" do
    it "adds any new contexts" do
      task = create_task("my task @foo")

      task.contexts = ["@foo", "@bar"]

      expect(task.contexts).to eq(["@foo", "@bar"])
      expect(task.raw).to eq("my task @foo @bar")
    end

    it "removes any existing contexts not included" do
      task = create_task("my task @foo")

      task.contexts = ["@bar"]

      expect(task.contexts).to eq(["@bar"])
      expect(task.raw).to eq("my task @bar")
    end

    it "preserves order and number of contexts" do
      task = create_task("@foo text @foo @bar text @baz @bar")

      task.contexts = ["@foo", "@baz", "@baz", "@new"]

      expect(task.contexts).to eq(["@foo", "@baz", "@baz", "@new"])
      expect(task.raw).to eq("@foo text text @baz @baz @new")
    end
  end

  describe "#projects=" do
    it "adds any new projects" do
      task = create_task("my task +foo")

      task.projects = ["+foo", "+bar"]

      expect(task.projects).to eq(["+foo", "+bar"])
      expect(task.raw).to eq("my task +foo +bar")
    end

    it "removes any existing projects not included" do
      task = create_task("my task +foo")

      task.projects = ["+bar"]

      expect(task.projects).to eq(["+bar"])
      expect(task.raw).to eq("my task +bar")
    end

    it "preserves order and number of projects" do
      task = create_task("+foo text +foo +bar text +baz +bar")

      task.projects = ["+foo", "+baz", "+baz", "+new"]

      expect(task.projects).to eq(["+foo", "+baz", "+baz", "+new"])
      expect(task.raw).to eq("+foo text text +baz +baz +new")
    end
  end

  describe "#tags=" do
    it "adds any new tags" do
      task = create_task("my task foo:1")

      task.tags = {foo: 1, bar: 2}

      expect(task.tags).to eq({foo: "1", bar: "2"})
      expect(task.raw).to eq("my task foo:1 bar:2")
    end

    it "removes any existing tags not included" do
      task = create_task("my task foo:1")

      task.tags = {bar: 2}

      expect(task.tags).to eq({bar: "2"})
      expect(task.raw).to eq("my task bar:2")
    end

    it "updates tag values in place" do
      task = create_task("my task foo:1 text")

      task.tags = {foo: 2}

      expect(task.tags).to eq({foo: "2"})
      expect(task.raw).to eq("my task foo:2 text")
    end
  end
end
