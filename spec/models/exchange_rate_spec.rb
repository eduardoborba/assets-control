require "rails_helper"

RSpec.describe ExchangeRate, type: :model do
  describe "validations" do
    it { should validate_presence_of(:base_currency) }
    it { should validate_length_of(:base_currency).is_equal_to(3) }
    it { should validate_presence_of(:quote_currency) }
    it { should validate_length_of(:quote_currency).is_equal_to(3) }
    it { should validate_presence_of(:rate) }
    it { should validate_numericality_of(:rate).is_greater_than(0) }
    it { should validate_presence_of(:fetched_on) }

    it "validates uniqueness of base_currency scoped to quote_currency and fetched_on" do
      create(:exchange_rate, base_currency: "USD", quote_currency: "BRL", fetched_on: Date.current)

      duplicate = build(:exchange_rate, base_currency: "USD", quote_currency: "BRL", fetched_on: Date.current)
      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    describe ".for_pair" do
      it "returns rates for a specific currency pair" do
        usd_brl = create(:exchange_rate, base_currency: "USD", quote_currency: "BRL")
        usd_eur = create(:exchange_rate, base_currency: "USD", quote_currency: "EUR")

        expect(ExchangeRate.for_pair("USD", "BRL")).to include(usd_brl)
        expect(ExchangeRate.for_pair("USD", "BRL")).not_to include(usd_eur)
      end
    end

    describe ".on_date" do
      it "returns rates for a specific date" do
        today = create(:exchange_rate, fetched_on: Date.current)
        yesterday = create(:exchange_rate, fetched_on: 1.day.ago)

        expect(ExchangeRate.on_date(Date.current)).to include(today)
        expect(ExchangeRate.on_date(Date.current)).not_to include(yesterday)
      end
    end
  end

  describe ".find_rate" do
    it "returns the most recent rate for a pair on or before the given date" do
      old_rate = create(:exchange_rate, base_currency: "USD", quote_currency: "BRL", rate: 5.0, fetched_on: 1.week.ago)
      new_rate = create(:exchange_rate, base_currency: "USD", quote_currency: "BRL", rate: 5.2, fetched_on: 1.day.ago)

      result = ExchangeRate.find_rate(base: "USD", quote: "BRL", on_date: Date.current)
      expect(result).to eq(new_rate)
    end

    it "returns nil when no rate exists" do
      result = ExchangeRate.find_rate(base: "USD", quote: "BRL", on_date: 1.year.ago)
      expect(result).to be_nil
    end
  end
end
