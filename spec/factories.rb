FactoryBot.define do
  factory :delta do
    type { Delta::ADD }
    arguments { ["an argument"] * Delta::TYPE_CONFIGS[type].valid_arguments_length }
    status { Delta::UNAPPLIED }
  end
end
