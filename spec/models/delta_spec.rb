require 'rails_helper'

RSpec.describe Delta do
  context 'validations' do
    it { should validate_presence_of(:type) }
    it do
      should validate_inclusion_of(:type).in_array( Delta::TYPES)
    end
    it { should validate_presence_of(:arguments) }
  end

  describe '.pending' do
    it 'gives deltas ordered by date created' do
      deltas = create_list(:delta, 3, applied: false)

      expect(Delta.pending).to eq(deltas)
    end

    it 'excludes applied deltas' do
      delta = create(:delta, applied: true)

      expect(Delta.pending).to eq([])
    end
  end
end
