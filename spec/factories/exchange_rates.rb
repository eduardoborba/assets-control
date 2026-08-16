FactoryBot.define do
  factory :exchange_rate do
    base_currency { "USD" }
    quote_currency { "BRL" }
    rate { 52_000 }
    fetched_on { Date.current }
  end
end
