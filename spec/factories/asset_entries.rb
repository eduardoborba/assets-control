FactoryBot.define do
  factory :asset_entry do
    association :snapshot
    association :asset
    amount { 1000.00 }
    dollar_rate { nil }

    trait :usd do
      association :asset, :usd
      dollar_rate { 5.20 }
    end

    trait :brl do
      association :asset, :brl
      dollar_rate { nil }
    end
  end
end
