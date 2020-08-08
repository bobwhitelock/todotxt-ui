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
end
