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

    context "when `task_class` Config option set" do
      class CustomTask < Todotxt::Task; end

      before :each do
        Todotxt.config = Todotxt::Config.new(task_class: CustomTask)
      end

      after :each do
        Todotxt.config = Todotxt::Config.new
      end

      it "uses given class when creating Tasks internally" do
        list = described_class.new(["foo"])

        expect(list[0]).to be_a(CustomTask)
        expect(list[0].raw).to eq("foo")
      end

      it "converts any Tasks passed to given class" do
        list = described_class.new([create_task("foo")])

        expect(list[0]).to be_a(CustomTask)
        expect(list[0].raw).to eq("foo")
      end
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

  describe "#file=" do
    it "assigns `file` for List" do
      list = described_class.new

      list.file = "/some/path"

      expect(list.file).to eq("/some/path")
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

    it "converts any strings replaced in List to Tasks" do
      list = described_class.new(["foo"])

      list[0] = "bar"

      expected_tasks = [create_task("bar")]
      expect(list.to_a).to eq(expected_tasks)
    end

    it "prevents blank Tasks from being included in List" do
      list = described_class.new(["foo"])

      list << ""
      list.concat([" ", "\n\n", "\t"])

      expect(list.to_a).to eq([create_task("foo")])
    end
  end

  describe "#save" do
    context "when no arguments passed" do
      it "saves List Tasks to configured file" do
        file = Tempfile.new.path
        list = described_class.new(["foo", "bar"], file: file)

        list.save

        file_content = File.read(file)
        expect(file_content).to eq("foo\nbar\n")
      end

      it "raises when no configured file" do
        list = described_class.new(["foo", "bar"])

        expect {
          list.save
        }.to raise_error(Todotxt::UsageError, "No file set for #{list}")
      end
    end

    context "when file path passed" do
      it "saves List Tasks to given file" do
        file = Tempfile.new.path
        list = described_class.new(["foo", "bar"])

        list.save(file)

        file_content = File.read(file)
        expect(file_content).to eq("foo\nbar\n")
      end

      it "raises default error if bad file path given" do
        list = described_class.new(["foo", "bar"])

        expect {
          list.save("/some/non/existent/path")
        }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe "#as_string" do
    it "returns the raw content of List as would be saved" do
      list = described_class.new(["foo", "bar"])

      expect(list.as_string).to eq("foo\nbar\n")
    end
  end

  describe "#raw_tasks" do
    it "returns array of raw text for all List Tasks" do
      list = described_class.new(["foo", "bar"])

      expect(list.raw_tasks).to eq(["foo", "bar"])
    end
  end

  describe "#reload" do
    let :file do
      Tempfile.new.tap do |f|
        f << "task 1\n"
        f << "task 2\n"
        f.write
        f.flush
        f.rewind
      end
    end

    it "reloads List Tasks from configured `file`" do
      list = described_class.new(file: file.path)

      result = list.reload

      expect(list.to_a).to eq([
        create_task("task 1"),
        create_task("task 2")
      ])
      expect(result).to eq(list)
    end

    it "raises when no configured file" do
      list = described_class.new

      expect {
        list.reload
      }.to raise_error(Todotxt::UsageError, "No file set for #{list}")
    end
  end

  describe "#dirty?" do
    subject do
      described_class.new(["foo", "bar"])
    end

    it "returns true if any List Task has been modified from original value on creation" do
      subject[0].contexts += ["@work"]

      expect(subject).to be_dirty
    end

    it "returns false if no List Tasks have been modified" do
      expect(subject).not_to be_dirty
    end

    it "returns true if a List Task has been added" do
      subject << "a task"

      expect(subject).to be_dirty
    end

    it "returns true if a List Task has been deleted" do
      subject.reject! { |task| task.raw == "bar" }

      expect(subject).to be_dirty
    end

    it "returns false if List Tasks have been modified but the List is the same as created" do
      subject.reject! { |task| task.raw == "bar" }
      subject << "bar"

      expect(subject).not_to be_dirty
    end

    it "returns false if List Tasks have been modified and then saved" do
      subject << "a task"
      subject.save(Tempfile.new)

      expect(subject).not_to be_dirty
    end
  end

  describe "#archive_to" do
    subject do
      described_class.new([
        "task 1",
        "x task 2",
        "task 3",
        "x task 4"
      ])
    end

    let :archive_file do
      Tempfile.new.tap do |f|
        f << "x existing task\n"
        f.write
        f.flush
        f.rewind
      end
    end

    let :archive_list do
      described_class.load(archive_file.path)
    end

    let :expected_list_tasks do
      [
        create_task("task 1"),
        create_task("task 3")
      ]
    end

    let :expected_archive_tasks do
      [
        create_task("x existing task"),
        create_task("x task 2"),
        create_task("x task 4")
      ]
    end

    it "saves List Tasks when List has `file` configured" do
      subject.file = Tempfile.new.path

      subject.archive_to(archive_file)

      expect(subject.reload.to_a).to eq(expected_list_tasks)
    end

    context "given file path" do
      it "archives completed List Tasks to given file" do
        subject.archive_to(archive_file.path)

        expect(subject.to_a).to eq(expected_list_tasks)
        expect(archive_list.to_a).to eq(expected_archive_tasks)
      end
    end

    context "given file object" do
      it "archives completed List Tasks to given file" do
        subject.archive_to(archive_file)

        expect(subject.to_a).to eq(expected_list_tasks)
        expect(archive_list.to_a).to eq(expected_archive_tasks)
      end
    end

    context "given List object" do
      it "archives completed List Tasks to given other List" do
        subject.archive_to(archive_list)

        expect(subject.to_a).to eq(expected_list_tasks)
        expect(archive_list.to_a).to eq(expected_archive_tasks)
        expect(archive_list.reload.to_a).to eq(expected_archive_tasks)
      end
    end
  end

  describe "#complete_tasks" do
    it "returns only complete Tasks in the List" do
      list = described_class.new([
        "task 1",
        "x task 2",
        "task 3",
        "x task 4"
      ])

      expect(list.complete_tasks).to eq([
        create_task("x task 2"),
        create_task("x task 4")
      ])
    end
  end

  describe "#incomplete_tasks" do
    it "returns only incomplete Tasks in the List" do
      list = described_class.new([
        "task 1",
        "x task 2",
        "task 3",
        "x task 4"
      ])

      expect(list.incomplete_tasks).to eq([
        create_task("task 1"),
        create_task("task 3")
      ])
    end
  end

  describe "#all_contexts" do
    it "returns sorted, de-duplicated contexts for all List Tasks" do
      list = described_class.new([
        "task 1 @foo @bar +proj",
        "task 2 @foo",
        "task 3 @baz @bar"
      ])

      expect(list.all_contexts).to eq(["@bar", "@baz", "@foo"])
    end
  end

  describe "#all_projects" do
    it "returns sorted, de-duplicated projects for all List Tasks" do
      list = described_class.new([
        "task 1 +foo +bar @context",
        "task 2 +foo",
        "task 3 +baz +bar"
      ])

      expect(list.all_projects).to eq(["+bar", "+baz", "+foo"])
    end
  end

  describe "#all_metadata_keys" do
    it "returns sorted, de-duplicated metadata keys for all List Tasks" do
      list = described_class.new([
        "task 1 foo:1 bar:2 @context",
        "task 2 foo:3",
        "task 3 baz:4 bar:5"
      ])

      expect(list.all_metadata_keys).to eq([:bar, :baz, :foo])
    end
  end
end
