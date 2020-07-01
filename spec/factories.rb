FactoryBot.define do
  factory :delta do
    type { 'add' }
    arguments { ['something'] }
    applied { false }
  end
end
