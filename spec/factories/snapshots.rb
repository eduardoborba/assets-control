FactoryBot.define do
  factory :snapshot do
    taken_on { Date.current }
    notes { nil }

    trait :with_entries do
      transient do
        assets_count { 3 }
      end

      after(:create) do |snapshot, evaluator|
        create_list(:asset_entry, evaluator.assets_count, snapshot: snapshot)
      end
    end
  end
end
