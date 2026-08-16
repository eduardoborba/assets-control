class FinancialAssetsController < ApplicationController
  before_action :set_financial_asset, only: %i[show edit update destroy]

  def index
    @financial_assets = Asset.active.by_position
  end

  def show
    @latest_entry = latest_entry_for(@financial_asset)
  end

  def new
    @financial_asset = Asset.new
  end

  def create
    @financial_asset = Asset.new(financial_asset_params)
    @financial_asset.position = Asset.maximum(:position).to_i + 1

    if @financial_asset.save
      redirect_to financial_assets_url, notice: "Asset was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @financial_asset.update(financial_asset_params)
      redirect_to financial_asset_path(@financial_asset), notice: "Asset was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @financial_asset.destroy
    redirect_to financial_assets_url, notice: "Asset was successfully destroyed."
  end

  def reorder
    asset_ids = params[:asset_ids]
    asset_ids.each_with_index do |id, index|
      Asset.where(id: id).update_all(position: index + 1)
    end
    head :ok
  end

  private

  def set_financial_asset
    @financial_asset = Asset.find(params[:id])
  end

  def financial_asset_params
    params.require(:asset).permit(:name, :category, :currency, :liquid, :archived)
  end

  def latest_entry_for(asset)
    AssetEntry.joins(:snapshot)
              .where(asset: asset)
              .order("snapshots.taken_on DESC")
              .first
  end
end
