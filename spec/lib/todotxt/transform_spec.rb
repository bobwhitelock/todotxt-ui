require "rails_helper"

RSpec.describe Todotxt::Transform do
  subject { described_class.new }

  it "transforms `complete`" do
    expect(subject.apply(complete: "x")).to eq(complete: true)
  end

  it "transforms `creation_date`" do
    expect(subject.apply(creation_date: {
      year: "2020", month: "07", day: "06"
    })).to eq(
      creation_date: Date.new(2020, 7, 6)
    )
  end

  it "transforms `completion_date`" do
    expect(subject.apply(completion_date: {
      year: "2020", month: "07", day: "06"
    })).to eq(
      completion_date: Date.new(2020, 7, 6)
    )
  end

  it "transforms `description`" do
    expect(subject.apply(description: [
      {word: "do"},
      {word: "things"},
      {context: "@home"},
      {word: "and"},
      {word: "other"},
      {word: "stuff"}
    ])).to eq(description: [
      Todotxt::Text.new("do things"),
      Todotxt::Context.new("@home"),
      Todotxt::Text.new("and other stuff")
    ])
  end

  it "transforms `project`" do
    expect(
      subject.apply(project: "+foo")
    ).to eq(
      Todotxt::Project.new("+foo")
    )
  end

  it "transforms `context`" do
    expect(
      subject.apply(context: "@foo")
    ).to eq(
      Todotxt::Context.new("@foo")
    )
  end

  it "transforms key-value metadata" do
    expect(
      subject.apply(metadatum: {key: "mykey", value: "myvalue"})
    ).to eq(
      Todotxt::Metadatum.new("mykey", "myvalue")
    )
  end
end
