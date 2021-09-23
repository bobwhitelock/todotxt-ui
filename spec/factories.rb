FactoryBot.define do
  factory :delta do
    type { Delta::ADD }
    arguments do
      Delta::ARGUMENT_DEFINITIONS[type].map { |arg| [arg, "an argument"] }.to_h
    end
    status { Delta::UNAPPLIED }
  end
end
