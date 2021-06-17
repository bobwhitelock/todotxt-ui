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
      expect(task.metadata).to eq({})
      expect(task.raw).to eq(raw_task)
    end

    it "parses a complex todotxt task into a Task" do
      raw_task = "x (B) 2020-08-02 2019-07-01 do things @home and other stuff +important +housework foo:bar"

      task = described_class.new(raw_task)

      expect(task).to be_complete
      expect(task.priority).to eq("B")
      expect(task.completion_date).to eq(Date.new(2020, 8, 2))
      expect(task.creation_date).to eq(Date.new(2019, 7, 1))
      expect(task.description).to eq(
        "do things @home and other stuff +important +housework foo:bar"
      )
      expect(task.description_text).to eq("do things and other stuff")
      expect(task.contexts).to eq(["@home"])
      expect(task.projects).to eq(["+important", "+housework"])
      expect(task.metadata).to eq(foo: "bar")
      expect(task.raw).to eq(raw_task)
    end

    it "parses task metadata as appropriate values" do
      raw_task = "a task foo:bar due:2020-08-09 awesomeness:5"

      task = described_class.new(raw_task)

      expect(task.metadata).to eq({
        foo: "bar",
        due: Date.new(2020, 8, 9),
        awesomeness: 5
      })
    end

    it "exposes parsed text as strings" do
      raw_task = "(A) stuff @context +project metadata_key:metadata_value"

      task = described_class.new(raw_task)

      expect(task.priority).to be_a(String)
      expect(task.description).to be_a(String)
      expect(task.description_text).to be_a(String)
      expect(task.contexts.first).to be_a(String)
      expect(task.projects.first).to be_a(String)
      key, value = task.metadata.first
      # Metadata keys are actually Symbols as this is nicer to work with.
      expect(key).to be_a(Symbol)
      expect(value).to be_a(String)
    end

    it "trims any whitespace from passed raw task" do
      raw_task = "   a messy task  \n"

      task = described_class.new(raw_task)

      expect(task.raw).to eq("a messy task")
    end

    it "allows creating empty Tasks" do
      empty_tasks = [
        described_class.new(""),
        described_class.new,
        described_class.new(nil)
      ]

      raw_tasks = empty_tasks.map(&:raw)
      expect(raw_tasks).to eq(["", "", ""])
    end

    context "when `parse_code_blocks` Config option not set" do
      before :each do
        Todotxt.config = Todotxt::Config.new(parse_code_blocks: false)
      end

      it "does nothing special with backticks" do
        raw_task = "some text `with a @context and +project`"

        task = described_class.new(raw_task)

        expect(task.description).to eq(
          "some text `with a @context and +project`"
        )
        expect(task.description_text).to eq("some text `with a and")
        expect(task.contexts).to eq(["@context"])
        expect(task.projects).to eq(["+project`"])
        expect(task.raw).to eq("some text `with a @context and +project`")
      end
    end

    context "when `parse_code_blocks` Config option set" do
      before :each do
        Todotxt.config = Todotxt::Config.new(parse_code_blocks: true)
      end

      after :each do
        Todotxt.config = Todotxt::Config.new
      end

      it "parses anything within backticks as just text" do
        raw_task = "` @context and +project ` some more text `key:value`@realcontext ``"

        task = described_class.new(raw_task)

        expect(task.description).to eq(
          "`@context and +project` some more text `key:value` @realcontext ``"
        )
        expect(task.description_text).to eq(
          "`@context and +project` some more text `key:value` ``"
        )
        expect(task.contexts).to eq(["@realcontext"])
        expect(task.raw).to eq(
          "`@context and +project` some more text `key:value` @realcontext ``"
        )
      end
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

  describe "#to_s and #inspect" do
    it "returns useful representation of Task" do
      task = create_task("do some things")

      expected_result = '<Todotxt::Task: "do some things">'
      expect(task.to_s).to eq(expected_result)
      expect(task.inspect).to eq(expected_result)
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

    it "upcases priority if lowercase" do
      task = create_task("my task")

      task.priority = "b"

      expect(task.priority).to eq("B")
      expect(task.raw).to eq("(B) my task")
    end

    it "raises for invalid priority" do
      task = create_task("my task")

      expected_error = "`priority` must be a single uppercase letter"
      expect {
        task.priority = "aa"
      }.to raise_error Todotxt::UsageError, expected_error
      expect {
        task.priority = "5"
      }.to raise_error Todotxt::UsageError, expected_error
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

    it "raises if Task is not complete" do
      task = create_task("my task")

      expect {
        task.completion_date = Date.new(2020, 8, 10)
      }.to raise_error(
        Todotxt::UsageError,
        "Cannot set `completion_date` for incomplete task #{task}"
      )
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

  describe "#raw=" do
    it "replaces all parts of Task with parts of new parsed Task" do
      task = create_task("(B) 2020-08-22 do some things @home")

      task.raw = "2020-08-22 do other things @work"

      expect(task.raw).to eq("2020-08-22 do other things @work")
      expect(task.priority).to be nil
      expect(task.creation_date).to eq(Date.new(2020, 8, 22))
      expect(task.description).to eq("do other things @work")
      expect(task).to be_dirty
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

  describe "#metadata=" do
    it "adds any new metadata" do
      task = create_task("my task foo:1")

      task.metadata = {foo: 1, bar: "baz"}

      expect(task.metadata).to eq({foo: 1, bar: "baz"})
      expect(task.raw).to eq("my task foo:1 bar:baz")
    end

    it "removes any existing metadata not included" do
      task = create_task("my task foo:1")

      task.metadata = {bar: 2}

      expect(task.metadata).to eq({bar: 2})
      expect(task.raw).to eq("my task bar:2")
    end

    it "updates metadata values in place" do
      task = create_task("my task foo:1 text")
      date = Date.new(2038, 2, 1)

      task.metadata = {foo: date}

      expect(task.metadata).to eq({foo: date})
      expect(task.raw).to eq("my task foo:2038-02-01 text")
    end
  end
end
