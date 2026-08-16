require "rails_helper"

RSpec.describe Snapshot, type: :model do
  describe "validations" do
    subject { build(:snapshot, taken_on: Date.current) }

    it { should validate_presence_of(:taken_on) }
    it { should validate_uniqueness_of(:taken_on) }
  end

  describe "associations" do
    it { should have_many(:asset_entries).dependent(:destroy) }
  end

  describe "scopes" do
    describe ".chronological" do
      it "returns snapshots ordered by taken_on ascending" do
        later = create(:snapshot, taken_on: 1.month.ago)
        earlier = create(:snapshot, taken_on: 2.months.ago)

        expect(Snapshot.chronological).to eq([ earlier, later ])
      end
    end

    describe ".recent_first" do
      it "returns snapshots ordered by taken_on descending" do
        later = create(:snapshot, taken_on: 1.month.ago)
        earlier = create(:snapshot, taken_on: 2.months.ago)

        expect(Snapshot.recent_first).to eq([ later, earlier ])
      end
    end
  end

  describe "#previous" do
    it "returns the previous snapshot by date" do
      earlier = create(:snapshot, taken_on: 2.months.ago)
      current = create(:snapshot, taken_on: 1.month.ago)

      expect(current.previous).to eq(earlier)
    end

    it "returns nil when no previous snapshot exists" do
      snapshot = create(:snapshot, taken_on: 1.month.ago)

      expect(snapshot.previous).to be_nil
    end
  end

  describe "#total_brl_cents" do
    it "sums all entry values in BRL cents" do
      snapshot = create(:snapshot)
      brl_asset = create(:asset, :brl)
      usd_asset = create(:asset, :usd)

      create(:asset_entry, snapshot: snapshot, asset: brl_asset, amount: 100_000)
      create(:asset_entry, snapshot: snapshot, asset: usd_asset, amount: 10_000, dollar_rate: 52_000)

      expect(snapshot.total_brl_cents).to eq(152_000)
    end
  end

  describe "#liquid_total_brl_cents" do
    it "sums only liquid asset entry values in BRL cents" do
      snapshot = create(:snapshot)
      liquid_asset = create(:asset, liquid: true, currency: "BRL")
      illiquid_asset = create(:asset, :illiquid, currency: "BRL")

      create(:asset_entry, snapshot: snapshot, asset: liquid_asset, amount: 100_000)
      create(:asset_entry, snapshot: snapshot, asset: illiquid_asset, amount: 500_000)

      expect(snapshot.liquid_total_brl_cents).to eq(100_000)
    end
  end
end
