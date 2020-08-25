require "rails_helper"
require "support/todotxt_helpers"

RSpec.describe Todotxt::List do
  describe ".new" do
    it "creates a List from an array of Tasks and/or strings" do
      list = described_class.new([
        "a string task",
        create_task("a Task object")
      ])

      list_tasks = list.to_a
      expect(list_tasks[0]).to eq(create_task("a string task"))
      expect(list_tasks[1]).to eq(create_task("a Task object"))
    end

    it "creates an empty List when passed nothing" do
      list = described_class.new

      expect(list.to_a).to be_empty
    end

    it "does not create Tasks for lines with nothing but whitespace" do
      list = described_class.new([
        "   ",
        "\n\n",
        "\t\t"
      ])

      expect(list.to_a).to be_empty
    end
  end

  describe ".load" do
    let :file do
      Tempfile.new.tap do |f|
        f << "task 1\n"
        f << "task 2\n"
        f.write
        f.flush
        f.rewind
      end
    end

    context "given file path" do
      it "creates a List with a Task for each line of file" do
        list = described_class.load(file.path)

        expect(list.to_a).to eq([
          create_task("task 1"),
          create_task("task 2")
        ])
        expect(list.file).to eq(file.path)
      end
    end

    context "given file object" do
      it "creates a List with a Task for each line of file" do
        list = described_class.load(file)

        expect(list.to_a).to eq([
          create_task("task 1"),
          create_task("task 2")
        ])
        expect(list.file).to eq(file.path)
      end
    end

    context "given other IO object" do
      it "creates a List with a Task for each line of IO" do
        io = StringIO.new("task 1\ntask 2")

        list = described_class.load(io)

        expect(list.to_a).to eq([
          create_task("task 1"),
          create_task("task 2")
        ])
        expect(list.file).to be nil
      end
    end
  end

  describe ".load_from_string" do
    it "creates a List with a Task for each line of string" do
      list = described_class.load_from_string("task 1\ntask 2")

      expect(list.to_a).to eq([
        create_task("task 1"),
        create_task("task 2")
      ])
    end
  end

  describe "#to_s and #inspect" do
    it "returns useful representation of List" do
      list = described_class.new(["do some things", "other things"])

      expected_result = '<Todotxt::List: tasks=["do some things", "other things"]>'
      expect(list.to_s).to eq(expected_result)
      expect(list.inspect).to eq(expected_result)
    end

    it "includes file if set for List" do
      list = described_class.new(
        ["do some things", "other things"],
        file: "/tmp/foo.todo"
      )

      expected_result = '<Todotxt::List: file="/tmp/foo.todo" tasks=["do some things", "other things"]>'
      expect(list.to_s).to eq(expected_result)
      expect(list.inspect).to eq(expected_result)
    end
  end

  describe "Array method delegation" do
    it "only responds to Array methods" do
      list = described_class.new
      array_methods = [:size, :map!, :select]
      non_array_methods = [:size!, :foo]

      array_methods.each do |method|
        expect(list).to respond_to(method)
      end
      non_array_methods.each do |method|
        expect(list).not_to respond_to(method)
        expect { list.public_send(method) }.to raise_error(NoMethodError)
      end
    end

    it "delegates all Array methods to internal tasks Array" do
      list = described_class.new(["(A) foo", "(B) bar"])

      size = list.size
      descriptions = list.map(&:description)

      expect(size).to eq(2)
      expect(descriptions).to eq(["foo", "bar"])
    end

    it "converts any strings added to List to Tasks" do
      list = described_class.new(["foo"])

      result = list << "bar"

      # New Task should appear as a Task (rather than String) both when later
      # converting the List to an Array and in the return value from calling
      # the delegated method (if this is returning the Tasks Array); doing the
      # former but not the latter would be confusing.
      expected_tasks = [create_task("foo"), create_task("bar")]
      expect(list.to_a).to eq(expected_tasks)
      expect(result).to eq(expected_tasks)
    end

    it "prevents blank Tasks from being included in List" do
      list = described_class.new(["foo"])

      list << ""
      list.concat([" ", "\n\n", "\t"])

      expect(list.to_a).to eq([create_task("foo")])
    end
  end
end
