FactoryBot.define do
  factory :asset do
    name { "ETFs gringos" }
    category { "stocks" }
    currency { "USD" }
    liquid { true }
    archived { false }
    position { 1 }

    trait :brl do
      currency { "BRL" }
    end

    trait :usd do
      currency { "USD" }
    end

    trait :illiquid do
      liquid { false }
    end

    trait :archived do
      archived { true }
    end
  end
end
