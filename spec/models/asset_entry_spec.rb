require "rails_helper"

RSpec.describe AssetEntry, type: :model do
  describe "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0).only_integer }

    it "validates uniqueness of snapshot_id scoped to asset_id" do
      snapshot = create(:snapshot)
      asset = create(:asset, :brl)
      create(:asset_entry, snapshot: snapshot, asset: asset)

      duplicate = build(:asset_entry, snapshot: snapshot, asset: asset)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:snapshot_id]).to include("already has an entry for this asset")
    end

    it "requires dollar_rate for USD assets" do
      asset = create(:asset, :usd)
      entry = build(:asset_entry, asset: asset, dollar_rate: nil)

      expect(entry).not_to be_valid
      expect(entry.errors[:dollar_rate]).to include("is required for USD assets")
    end

    it "does not require dollar_rate for BRL assets" do
      asset = create(:asset, :brl)
      entry = build(:asset_entry, asset: asset, dollar_rate: nil)

      expect(entry).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:snapshot) }
    it { should belong_to(:asset) }
  end

  describe "#value_in_brl_cents" do
    it "returns amount directly for BRL assets" do
      asset = create(:asset, :brl)
      entry = build(:asset_entry, asset: asset, amount: 150_000)

      expect(entry.value_in_brl_cents).to eq(150_000)
    end

    it "returns amount multiplied by dollar_rate for USD assets" do
      asset = create(:asset, :usd)
      entry = build(:asset_entry, asset: asset, amount: 10_000, dollar_rate: 52_000)

      expect(entry.value_in_brl_cents).to eq(52_000)
    end

    it "returns 0 for USD assets without dollar_rate" do
      asset = create(:asset, :usd)
      entry = build(:asset_entry, asset: asset, amount: 10_000, dollar_rate: nil)

      expect(entry.value_in_brl_cents).to eq(0)
    end
  end
end
