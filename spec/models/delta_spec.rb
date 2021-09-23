require "rails_helper"

RSpec.describe Delta do
  context "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_inclusion_of(:type).in_array(Delta::TYPES) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Delta::STATUSES) }
    it { should validate_presence_of(:arguments) }

    it "validates correct arguments passed for each type of Delta" do
      missing_argument_delta = build(
        :delta, type: Delta::UPDATE, arguments: {task: "one"}
      )
      extra_argument_delta = build(
        :delta, type: Delta::ADD, arguments: {task: "one", new_task: "two"}
      )
      correct_delta = build(
        :delta, type: Delta::UPDATE, arguments: {task: "one", new_task: "two"}
      )

      expect(missing_argument_delta).to be_invalid
      expect(missing_argument_delta.errors[:arguments]).to eq([
        "This type of Delta expects these arguments: 'task', 'new_task'"
      ])
      expect(extra_argument_delta).to be_invalid
      expect(extra_argument_delta.errors[:arguments]).to eq([
        "This type of Delta expects these arguments: 'task'"
      ])
      expect(correct_delta).to be_valid
    end
  end

  describe ".pending" do
    it "gives deltas ordered by date created" do
      deltas = create_list(:delta, 3, status: Delta::UNAPPLIED)

      expect(Delta.pending).to eq(deltas)
    end

    it "excludes applied deltas" do
      create(:delta, status: Delta::APPLIED)

      expect(Delta.pending).to eq([])
    end
  end
end
