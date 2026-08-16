require "rails_helper"

RSpec.describe "FinancialAssets", type: :request do
  describe "GET /financial_assets" do
    it "returns a successful response" do
      create(:asset)
      get financial_assets_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /financial_assets/:id" do
    it "returns a successful response" do
      asset = create(:asset)
      get financial_asset_path(asset)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /financial_assets/new" do
    it "returns a successful response" do
      get new_financial_asset_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /financial_assets/:id/edit" do
    it "returns a successful response" do
      asset = create(:asset)
      get edit_financial_asset_path(asset)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /financial_assets" do
    context "with valid parameters" do
      it "creates a new asset with auto-assigned position" do
        expect {
          post financial_assets_path, params: { asset: { name: "New Asset", category: "stocks", currency: "USD", liquid: true } }
        }.to change(Asset, :count).by(1)

        expect(response).to redirect_to(financial_assets_path)
        expect(Asset.last.position).not_to be_nil
      end
    end

    context "with invalid parameters" do
      it "does not create a new asset" do
        expect {
          post financial_assets_path, params: { asset: { name: "", category: nil, currency: nil } }
        }.not_to change(Asset, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /financial_assets/:id" do
    context "with valid parameters" do
      it "updates the asset" do
        asset = create(:asset)
        patch financial_asset_path(asset), params: { asset: { name: "Updated Name" } }
        expect(asset.reload.name).to eq("Updated Name")
        expect(response).to redirect_to(financial_asset_path(asset))
      end
    end

    context "with invalid parameters" do
      it "does not update the asset" do
        asset = create(:asset)
        patch financial_asset_path(asset), params: { asset: { name: "" } }
        expect(asset.reload.name).to eq(asset.name)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /financial_assets/:id" do
    it "destroys the asset" do
      asset = create(:asset)
      expect {
        delete financial_asset_path(asset)
      }.to change(Asset, :count).by(-1)

      expect(response).to redirect_to(financial_assets_path)
    end

    it "does not destroy asset with entries" do
      asset = create(:asset, :brl)
      snapshot = create(:snapshot)
      create(:asset_entry, :brl, asset: asset, snapshot: snapshot)

      expect {
        delete financial_asset_path(asset)
      }.not_to change(Asset, :count)
    end
  end

  describe "PATCH /financial_assets/reorder" do
    it "updates asset positions" do
      asset1 = create(:asset, position: 1)
      asset2 = create(:asset, position: 2)

      patch reorder_financial_assets_path, params: { asset_ids: [asset2.id, asset1.id] }

      expect(response).to have_http_status(:ok)
      expect(asset1.reload.position).to eq(2)
      expect(asset2.reload.position).to eq(1)
    end
  end
end
