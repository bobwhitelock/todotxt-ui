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
        "foo bar @somewhere +proj1 @work +proj2 due:2038-02-01 something_else"
      ).as(description: [
        {word: "foo"},
        {word: "bar"},
        {context: "@somewhere"},
        {project: "+proj1"},
        {context: "@work"},
        {project: "+proj2"},
        {tag: {key: "due", value: "2038-02-01"}},
        {word: "something_else"}
      ])
    }
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
    it { expect(subject.identifier).to parse("with:some:colons") }
    it { expect(subject.identifier).not_to parse("foo bar") }
  end

  describe "key_value_tag" do
    it do
      expect(subject.key_value_tag).to parse("mykey:myvalue").as(
        tag: {key: "mykey", value: "myvalue"}
      )
    end
    it { expect(subject.key_value_tag).not_to parse("mykey:myvalue:something_else") }
    it { expect(subject.key_value_tag).not_to parse("my key:my value") }
  end

  describe "key_value_tag_identifier" do
    it { expect(subject.key_value_tag_identifier).to parse("something") }
    it { expect(subject.key_value_tag_identifier).to parse("5") }
    it { expect(subject.key_value_tag_identifier).to parse("😎") }
    # This is the one difference from the regular `identifier`.
    it { expect(subject.key_value_tag_identifier).not_to parse("with:some:colons") }
    it { expect(subject.key_value_tag_identifier).not_to parse("foo bar") }
  end

  describe "space" do
    it { expect(subject.space).to parse(" ") }
    # XXX Why doesn't this work?
    # it { expect(subject.space).to parse("\t") }
  end
end
