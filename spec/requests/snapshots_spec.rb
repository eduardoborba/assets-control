require "rails_helper"

RSpec.describe "Snapshots", type: :request do
  describe "GET /snapshots" do
    it "returns a successful response" do
      create(:snapshot)
      get snapshots_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /snapshots/:id" do
    it "returns a successful response" do
      snapshot = create(:snapshot)
      get snapshot_path(snapshot)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /snapshots/new" do
    it "returns a successful response" do
      get new_snapshot_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /snapshots/:id/edit" do
    it "returns a successful response" do
      snapshot = create(:snapshot)
      get edit_snapshot_path(snapshot)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /snapshots" do
    let!(:asset) { create(:asset, :brl) }

    context "with valid parameters" do
      it "creates a new snapshot with entries" do
        expect {
          post snapshots_path, params: {
            snapshot: {
              taken_on: Date.current,
              notes: "Test snapshot",
              asset_entries_attributes: { "0" => { asset_id: asset.id, amount: 100_000 } }
            }
          }
        }.to change(Snapshot, :count).by(1)
           .and change(AssetEntry, :count).by(1)

        expect(response).to redirect_to(snapshots_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new snapshot" do
        expect {
          post snapshots_path, params: {
            snapshot: { taken_on: nil }
          }
        }.not_to change(Snapshot, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /snapshots/:id" do
    let!(:snapshot) { create(:snapshot) }

    context "with valid parameters" do
      it "updates the snapshot" do
        patch snapshot_path(snapshot), params: { snapshot: { notes: "Updated" } }
        expect(snapshot.reload.notes).to eq("Updated")
        expect(response).to redirect_to(snapshots_path)
      end
    end
  end

  describe "DELETE /snapshots/:id" do
    it "destroys the snapshot" do
      snapshot = create(:snapshot)
      expect {
        delete snapshot_path(snapshot)
      }.to change(Snapshot, :count).by(-1)

      expect(response).to redirect_to(snapshots_path)
    end
  end

  describe "GET /snapshots/prefill" do
    it "returns entries from latest snapshot" do
      asset1 = create(:asset, :brl)
      asset2 = create(:asset, :usd)
      snapshot = create(:snapshot, taken_on: 1.day.ago)
      create(:asset_entry, :brl, snapshot: snapshot, asset: asset1, amount: 5000)
      create(:asset_entry, :usd, snapshot: snapshot, asset: asset2, amount: 1000, dollar_rate: 5.20)

      get prefill_snapshots_path
      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)
      expect(data.length).to eq(2)
    end
  end
end
