FactoryBot.define do
  factory :delta do
    type { "add" }
    arguments { ["something"] }
    status { Delta::UNAPPLIED }
  end
end
