require "rails_helper"

RSpec.describe ExchangeRateFetcher do
  let(:date) { Date.current }

  describe "#call" do
    context "when rate is cached" do
      before do
        create(:exchange_rate, base_currency: "USD", quote_currency: "BRL", rate: 5.20, fetched_on: date)
      end

      it "returns cached rate without API call" do
        result = described_class.new(date: date).call
        expect(result).to eq(5.20)
      end
    end

    context "when rate is not cached", vcr: { cassette_name: "exchange_rate/success" } do
      it "fetches rate from API and caches it" do
        result = described_class.new(date: date).call

        expect(result).to be_a(Numeric)
        expect(ExchangeRate.count).to eq(1)
        expect(ExchangeRate.last.base_currency).to eq("USD")
        expect(ExchangeRate.last.quote_currency).to eq("BRL")
      end
    end

    context "when API fails", vcr: { cassette_name: "exchange_rate/not_found" } do
      it "returns default rate when no fallback exists" do
        result = described_class.new(date: date).call
        expect(result).to eq(5.20)
      end

      it "returns nearest cached rate as fallback" do
        create(:exchange_rate, base_currency: "USD", quote_currency: "BRL", rate: 5.10, fetched_on: 1.day.ago)

        result = described_class.new(date: date).call
        expect(result).to eq(5.10)
      end
    end
  end
end
