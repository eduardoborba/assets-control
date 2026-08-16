require "rails_helper"

RSpec.describe DashboardService do
  describe "#call" do
    let(:brl_asset) { create(:asset, :brl, category: "stocks") }
    let(:usd_asset) { create(:asset, :usd, category: "fixed_income", liquid: true) }
    let(:illiquid_asset) { create(:asset, :brl, :illiquid, category: "real_estate") }

    let!(:snapshot1) do
      create(:snapshot, taken_on: 2.months.ago).tap do |s|
        create(:asset_entry, snapshot: s, asset: brl_asset, amount: 1000)
        create(:asset_entry, snapshot: s, asset: usd_asset, amount: 100, dollar_rate: 5.0)
        create(:asset_entry, snapshot: s, asset: illiquid_asset, amount: 5000)
      end
    end

    let!(:snapshot2) do
      create(:snapshot, taken_on: 1.month.ago).tap do |s|
        create(:asset_entry, snapshot: s, asset: brl_asset, amount: 1100)
        create(:asset_entry, snapshot: s, asset: usd_asset, amount: 110, dollar_rate: 5.2)
        create(:asset_entry, snapshot: s, asset: illiquid_asset, amount: 5100)
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

      expect(result[0][:total]).to eq(1000 + 500 + 5000)
      expect(result[1][:total]).to eq(1100 + 572 + 5100)
    end

    it "calculates liquid total correctly" do
      result = described_class.new.call

      expect(result[0][:liquid_total]).to eq(1000 + 500)
      expect(result[1][:liquid_total]).to eq(1100 + 572)
    end

    it "groups by category" do
      result = described_class.new.call

      expect(result[0][:by_category]).to include("stocks" => 1000, "fixed_income" => 500, "real_estate" => 5000)
    end

    it "groups by currency" do
      result = described_class.new.call

      expect(result[0][:by_currency]).to include("BRL" => 6000, "USD" => 500)
    end
  end
end
