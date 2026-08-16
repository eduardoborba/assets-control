require "rails_helper"

RSpec.describe EntryValueService do
  describe "#call" do
    context "when asset is in BRL" do
      let(:asset) { create(:asset, :brl) }
      let(:entry) { create(:asset_entry, asset: asset, amount: 150_050) }

      it "returns amount directly" do
        result = described_class.new(entry).call
        expect(result).to eq(150_050)
      end
    end

    context "when asset is in USD" do
      let(:asset) { create(:asset, :usd) }

      it "returns amount multiplied by dollar_rate" do
        entry = create(:asset_entry, asset: asset, amount: 10_000, dollar_rate: 52_000)
        result = described_class.new(entry).call
        expect(result).to eq(52_000)
      end

      it "returns 0 when dollar_rate is nil" do
        entry = build(:asset_entry, asset: asset, amount: 10_000, dollar_rate: nil)
        result = described_class.new(entry).call
        expect(result).to eq(0)
      end
    end
  end
end
