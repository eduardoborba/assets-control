require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    it "returns a successful response" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "displays the dashboard title" do
      get root_path
      expect(response.body).to include("Dashboard")
    end

    context "when there are snapshots" do
      let!(:asset) { create(:asset, :brl, category: "stocks") }
      let!(:snapshot) do
        create(:snapshot, taken_on: 1.month.ago).tap do |s|
          create(:asset_entry, snapshot: s, asset: asset, amount: 100_000)
        end
      end

      it "displays summary cards" do
        get root_path
        expect(response.body).to include("Patrimônio Total")
        expect(response.body).to include("Patrimônio Líquido")
        expect(response.body).to include("Variação")
        expect(response.body).to include("Qtd Ativos")
      end

      it "displays the latest snapshot table" do
        get root_path
        expect(response.body).to include(asset.name)
      end
    end

    context "when there are no snapshots" do
      it "displays empty state message" do
        get root_path
        expect(response.body).to include("Nenhum snapshot encontrado")
      end
    end
  end
end
