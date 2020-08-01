require "rails_helper"

RSpec.describe Delta do
  context "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_inclusion_of(:type).in_array(Delta::TYPES) }
    context "when status is `invalid`" do
      subject { create(:delta, status: Delta::INVALID) }
      it { should validate_presence_of(:type) }
      it { should_not validate_inclusion_of(:type).in_array(Delta::TYPES) }
    end
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Delta::STATUSES) }
    it { should validate_presence_of(:arguments) }
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

    it "excludes invalid deltas" do
      create(:delta, status: Delta::INVALID)

      expect(Delta.pending).to eq([])
    end
  end
end
