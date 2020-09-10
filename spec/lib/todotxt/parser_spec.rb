require "rails_helper"
require "parslet/rig/rspec"

RSpec.describe Todotxt::Parser do
  subject { described_class.new }

  describe "task" do
    it "parses a simple incomplete task" do
      expect(subject.task).to parse("do things @home").as(
        task: {
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    it "parses an incomplete task with a priority" do
      expect(subject.task).to parse("(B) do things @home").as(
        task: {
          priority: "B",
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    it "parses an incomplete task with a creation_date" do
      expect(subject.task).to parse("2020-08-02 do things @home").as(
        task: {
          creation_date: {year: "2020", month: "08", day: "02"},
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    it "parses an incomplete task with a priority and creation_date" do
      expect(subject.task).to parse("(B) 2020-08-02 do things @home").as(
        task: {
          priority: "B",
          creation_date: {year: "2020", month: "08", day: "02"},
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    it "parses a simple complete task" do
      expect(subject.task).to parse("x do things @home").as(
        task: {
          complete: "x",
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    # It is unclear from the official todotxt format description how dates
    # should be handled for completed tasks. We take the reasonable/lenient
    # approach that:
    #
    # - it is valid to have no date present for a completed task;
    # - if one date is present, this is the `completion_date`;
    # - if two dates are present, the first is the `completion_date` and the
    # second is the `creation_date`.
    #
    # See https://github.com/todotxt/todo.txt/issues/26 for more info.
    it "parses a complete task with a completion_date" do
      expect(subject.task).to parse("x 2020-08-02 do things @home").as(
        task: {
          complete: "x",
          completion_date: {year: "2020", month: "08", day: "02"},
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    it "parses a complete task with a completion_date and creation_date" do
      expect(subject.task).to parse("x 2020-08-02 2019-07-01 do things @home").as(
        task: {
          complete: "x",
          completion_date: {year: "2020", month: "08", day: "02"},
          creation_date: {year: "2019", month: "07", day: "01"},
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end

    # According to
    # https://github.com/todotxt/todo.txt/blob/b5c5f5ca9abdd971a762fc9ca38e977107dc59a7/README.md#rule-2-the-date-of-completion-appears-directly-after-the-x-separated-by-a-space,
    # "Many Todo.txt clients discard priority on task completion. To preserve
    # it, use the `key:value` format described below (e.g. `pri:A`)".
    #
    # However it still appears valid to leave priorities present on completed
    # tasks in the usual format, therefore we handle parsing this.
    it "parses a complete task with a priority" do
      expect(subject.task).to parse("x (B) do things @home").as(
        task: {
          complete: "x",
          priority: "B",
          description: [
            {word: "do"},
            {word: "things"},
            {context: "@home"}
          ]
        }
      )
    end
  end

  describe "complete" do
    it { expect(subject.complete).to parse("x").as(complete: "x") }
    it { expect(subject.complete).not_to parse("xylophone") }
  end

  describe "priority" do
    it { expect(subject.priority).to parse("(A)").as(priority: "A") }
    it { expect(subject.priority).not_to parse("(a)") }
    it { expect(subject.priority).not_to parse(" (a)") }
  end

  describe "date" do
    it do
      expect(subject.date).to parse("2020-07-06").as(
        year: "2020", month: "07", day: "06"
      )
    end
  end

  describe "description" do
    it {
      expect(subject.description).to parse(
        "foo bar @somewhere +proj1 @work +proj2 mykey:myvalue something_else"
      ).as(description: [
        {word: "foo"},
        {word: "bar"},
        {context: "@somewhere"},
        {project: "+proj1"},
        {context: "@work"},
        {project: "+proj2"},
        {metadatum: {key: "mykey", value: "myvalue"}},
        {word: "something_else"}
      ])
    }

    context "when `parse_code_blocks` option passed" do
      subject do
        described_class.new(parse_code_blocks: true)
      end

      it "parses anything within backticks as a code block" do
        expect(subject.description).to parse(
          "` @context and +project ` something `key:value`@realcontext`foo`"
        ).as(description: [
          {code_block: [
            {word: "@context"},
            {word: "and"},
            {word: "+project"}
          ]},
          {word: "something"},
          {code_block: [
            {word: "key:value"}
          ]},
          {context: "@realcontext"},
          {code_block: [
            {word: "foo"}
          ]}
        ])
      end

      it "correctly parses when inconsistent number of backticks present" do
        expect(subject.description).to parse(
          "`foo` `bar baz"
        ).as(description: [
          {code_block: [{word: "foo"}]},
          {word: "`"},
          {word: "bar"},
          {word: "baz"}
        ])
      end

      it "correctly parses backticks in middle of word" do
        expect(subject.description).to parse("foo`bar`baz").as(description: [
          {word: "foo"},
          {code_block: [{word: "bar"}]},
          {word: "baz"}
        ])
      end
    end
  end

  describe "code_block" do
    context "when `parse_code_blocks` option passed" do
      subject do
        described_class.new(parse_code_blocks: true)
      end

      it do
        expect(subject.code_block).to parse(
          "`@context and +project`"
        ).as(code_block: [
          {word: "@context"},
          {word: "and"},
          {word: "+project"}
        ])
      end
    end

    context "when `parse_code_blocks` option not passed" do
      it do
        expect {
          subject.code_block.parse("anything")
        }.to raise_error(
          Todotxt::InternalError,
          "Invalid to call `code_block` when `parse_code_blocks` option not set"
        )
      end
    end
  end

  describe "project" do
    it { expect(subject.project).to parse("+myproject").as(project: "+myproject") }
  end

  describe "context" do
    it { expect(subject.context).to parse("@mycontext").as(context: "@mycontext") }
  end

  describe "identifier" do
    it { expect(subject.identifier).to parse("something") }
    it { expect(subject.identifier).to parse("5") }
    it { expect(subject.identifier).to parse("😎") }
    it { expect(subject.identifier).to parse("`with_backticks`") }
    it { expect(subject.identifier).to parse("with:some:colons") }
    it { expect(subject.identifier).not_to parse("foo bar") }

    context "when `parse_code_blocks` option passed" do
      subject do
        described_class.new(parse_code_blocks: true)
      end

      it { expect(subject.identifier).not_to parse("`with_backticks`") }
    end
  end

  describe "metadatum" do
    it "parses metadata with simple values" do
      expect(subject.metadatum).to parse("mykey:myvalue").as(
        metadatum: {key: "mykey", value: "myvalue"}
      )
    end

    it "parses metadata with date values" do
      expect(subject.metadatum).to parse("due:2038-02-01").as(
        metadatum: {
          key: "due",
          value: {year: "2038", month: "02", day: "01"}
        }
      )
    end

    it { expect(subject.metadatum).not_to parse("mykey:myvalue:something_else") }
    it { expect(subject.metadatum).not_to parse("my key:my value") }
  end

  describe "metadatum_identifier" do
    it { expect(subject.metadatum_identifier).to parse("something") }
    it { expect(subject.metadatum_identifier).to parse("5") }
    it { expect(subject.metadatum_identifier).to parse("😎") }
    it { expect(subject.metadatum_identifier).to parse("`with_backticks`") }
    # This is the one difference from the regular `identifier`.
    it { expect(subject.metadatum_identifier).not_to parse("with:some:colons") }
    it { expect(subject.metadatum_identifier).not_to parse("foo bar") }

    context "when `parse_code_blocks` option passed" do
      subject do
        described_class.new(parse_code_blocks: true)
      end

      it do
        expect(subject.metadatum_identifier).not_to parse("`with_backticks`")
      end
    end
  end

  describe "space" do
    it { expect(subject.space).to parse(" ") }
  end
end
