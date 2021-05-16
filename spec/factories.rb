FactoryBot.define do
  factory :delta do
    type { "add" }
    arguments { ["an argument"] * Delta::TYPE_CONFIGS[type].valid_arguments_length }
    status { Delta::UNAPPLIED }
  end
end
