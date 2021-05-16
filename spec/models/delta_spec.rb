require "rails_helper"

RSpec.describe Delta do
  context "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_inclusion_of(:type).in_array(Delta::TYPES) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Delta::STATUSES) }
    it { should validate_presence_of(:arguments) }

    it "validates correct number of arguments passed for each type of Delta" do
      one_arg_update_delta = build(:delta, type: Delta::UPDATE, arguments: ["one"])
      two_arg_update_delta = build(:delta, type: Delta::UPDATE, arguments: ["one", "two"])
      other_delta_types = Delta::TYPES - [Delta::UPDATE]
      one_arg_other_deltas = other_delta_types.map do |t|
        build(:delta, type: t, arguments: ["one"])
      end
      two_arg_other_deltas = other_delta_types.map do |t|
        build(:delta, type: t, arguments: ["one", "two"])
      end

      expect(one_arg_update_delta).to be_invalid
      expect(one_arg_update_delta.errors[:arguments]).to eq([
        "This type of Delta expects 2 arguments"
      ])
      expect(two_arg_update_delta).to be_valid
      one_arg_other_deltas.each { |d| expect(d).to be_valid }
      two_arg_other_deltas.each do |d|
        expect(d).to be_invalid
        expect(d.errors[:arguments]).to eq([
          "This type of Delta expects 1 argument"
        ])
      end
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
