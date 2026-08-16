require "rails_helper"

RSpec.describe Asset, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:currency) }
    it { should validate_length_of(:currency).is_equal_to(3) }
    it { should validate_numericality_of(:position).only_integer }
  end

  describe "associations" do
    it { should have_many(:asset_entries).dependent(:restrict_with_error) }
  end

  describe "enums" do
    it { should define_enum_for(:category).with_values(stocks: "stocks", fixed_income: "fixed_income", real_estate: "real_estate", vehicle: "vehicle", insurance: "insurance", bank_account: "bank_account", other: "other").backed_by_column_of_type(:string) }
  end

  describe "scopes" do
    let!(:active_asset) { create(:asset, archived: false) }
    let!(:archived_asset) { create(:asset, :archived) }
    let!(:liquid_asset) { create(:asset, liquid: true) }
    let!(:illiquid_asset) { create(:asset, :illiquid) }

    describe ".active" do
      it "returns non-archived assets" do
        expect(Asset.active).to include(active_asset)
        expect(Asset.active).not_to include(archived_asset)
      end
    end

    describe ".liquid" do
      it "returns liquid assets" do
        expect(Asset.liquid).to include(liquid_asset)
        expect(Asset.liquid).not_to include(illiquid_asset)
      end
    end

    describe ".by_position" do
      it "returns assets ordered by position" do
        asset1 = create(:asset, position: 2)
        asset2 = create(:asset, position: 1)

        result = Asset.where(id: [ asset1.id, asset2.id ]).by_position
        expect(result.pluck(:id)).to eq([ asset2.id, asset1.id ])
      end
    end
  end

  describe "instance methods" do
    describe "#brl?" do
      it "returns true when currency is BRL" do
        asset = build(:asset, :brl)
        expect(asset.brl?).to be true
      end

      it "returns false when currency is USD" do
        asset = build(:asset, :usd)
        expect(asset.brl?).to be false
      end
    end

    describe "#usd?" do
      it "returns true when currency is USD" do
        asset = build(:asset, :usd)
        expect(asset.usd?).to be true
      end

      it "returns false when currency is BRL" do
        asset = build(:asset, :brl)
        expect(asset.usd?).to be false
      end
    end
  end
end
