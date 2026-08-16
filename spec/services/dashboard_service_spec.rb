require "rails_helper"

RSpec.describe DashboardService do
  describe "#call" do
    let(:brl_asset) { create(:asset, :brl, category: "stocks") }
    let(:usd_asset) { create(:asset, :usd, category: "fixed_income", liquid: true) }
    let(:illiquid_asset) { create(:asset, :brl, :illiquid, category: "real_estate") }

    let!(:snapshot1) do
      create(:snapshot, taken_on: 2.months.ago).tap do |s|
        create(:asset_entry, snapshot: s, asset: brl_asset, amount: 100_000)
        create(:asset_entry, snapshot: s, asset: usd_asset, amount: 10_000, dollar_rate: 50_000)
        create(:asset_entry, snapshot: s, asset: illiquid_asset, amount: 500_000)
      end
    end

    let!(:snapshot2) do
      create(:snapshot, taken_on: 1.month.ago).tap do |s|
        create(:asset_entry, snapshot: s, asset: brl_asset, amount: 110_000)
        create(:asset_entry, snapshot: s, asset: usd_asset, amount: 11_000, dollar_rate: 52_000)
        create(:asset_entry, snapshot: s, asset: illiquid_asset, amount: 510_000)
      end
    end

    it "returns data for all snapshots in chronological order" do
      result = described_class.new.call

      expect(result.length).to eq(2)
      expect(result[0][:date]).to eq(2.months.ago.to_date)
      expect(result[1][:date]).to eq(1.month.ago.to_date)
    end

    it "calculates total BRL correctly" do
      result = described_class.new.call

      expect(result[0][:total_cents]).to eq(100_000 + 50_000 + 500_000)
      expect(result[1][:total_cents]).to eq(110_000 + 57_200 + 510_000)
    end

    it "calculates liquid total correctly" do
      result = described_class.new.call

      expect(result[0][:liquid_total_cents]).to eq(100_000 + 50_000)
      expect(result[1][:liquid_total_cents]).to eq(110_000 + 57_200)
    end

    it "groups by category" do
      result = described_class.new.call

      expect(result[0][:by_category_cents]).to include("stocks" => 100_000, "fixed_income" => 50_000, "real_estate" => 500_000)
    end

    it "groups by currency" do
      result = described_class.new.call

      expect(result[0][:by_currency_cents]).to include("BRL" => 600_000, "USD" => 50_000)
    end
  end
end
