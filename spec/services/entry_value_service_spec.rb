require "rails_helper"

RSpec.describe EntryValueService do
  describe "#call" do
    context "when asset is in BRL" do
      let(:asset) { create(:asset, :brl) }
      let(:entry) { create(:asset_entry, asset: asset, amount: 1500.50) }

      it "returns amount directly" do
        result = described_class.new(entry).call
        expect(result).to eq(1500.50)
      end
    end

    context "when asset is in USD" do
      let(:asset) { create(:asset, :usd) }

      it "returns amount multiplied by dollar_rate" do
        entry = create(:asset_entry, asset: asset, amount: 100, dollar_rate: 5.20)
        result = described_class.new(entry).call
        expect(result).to eq(520.0)
      end

      it "returns 0 when dollar_rate is nil" do
        entry = build(:asset_entry, asset: asset, amount: 100, dollar_rate: nil)
        result = described_class.new(entry).call
        expect(result).to eq(0)
      end
    end
  end
end
