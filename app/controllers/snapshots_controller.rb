class SnapshotsController < ApplicationController
  before_action :set_snapshot, only: %i[show edit update destroy]

  def index
    @snapshots = Snapshot.recent_first.includes(asset_entries: :asset)
  end

  def show; end

  def new
    @snapshot = Snapshot.new
    build_entries_for_active_assets
  end

  def create
    @snapshot = Snapshot.new(snapshot_params)

    if @snapshot.save
      redirect_to snapshots_url, notice: "Snapshot was successfully created."
    else
      build_entries_for_active_assets
      render :new, status: :unprocessable_content
    end
  end

  def edit
    build_entries_for_active_assets unless @snapshot.asset_entries.any?
  end

  def update
    if @snapshot.update(snapshot_params)
      redirect_to snapshots_url, notice: "Snapshot was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @snapshot.destroy
    redirect_to snapshots_url, notice: "Snapshot was successfully destroyed."
  end

  def prefill
    latest = Snapshot.recent_first.includes(asset_entries: :asset).first

    if latest
      render json: latest.asset_entries.map { |e|
        { asset_id: e.asset_id, amount: e.amount, dollar_rate: e.dollar_rate }
      }
    else
      render json: []
    end
  end

  def fetch_rate
    date = params[:date]
    rate = ExchangeRateFetcher.new(date: date).call
    render json: { rate: rate }
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end

  def snapshot_params
    params.require(:snapshot).permit(:taken_on, :notes, asset_entries_attributes: %i[id asset_id amount dollar_rate])
  end

  def build_entries_for_active_assets
    active_asset_ids = @snapshot.asset_entries.pluck(:asset_id)

    Asset.active.by_position.each do |asset|
      next if active_asset_ids.include?(asset.id)

      @snapshot.asset_entries.build(asset: asset)
    end
  end
end
