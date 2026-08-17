class DashboardController < ApplicationController
  include ApplicationHelper

  def index
    service = DashboardService.new
    @dashboard_data = service.call
    @latest_snapshot = Snapshot.recent_first.includes(asset_entries: :asset).first

    if @latest_snapshot
      @total_cents = @latest_snapshot.total_brl_cents
      @liquid_total_cents = @latest_snapshot.liquid_total_brl_cents
      @asset_count = Asset.active.count

      previous = @latest_snapshot.previous
      if previous
        @previous_total = previous.total_brl_cents
        @variation_cents = @total_cents - @previous_total
        @variation_pct = @previous_total > 0 ? (@variation_cents.to_f / @previous_total * 100).round(2) : 0
        @previous_entries = previous.asset_entries.index_by(&:asset_id)
      else
        @variation_cents = 0
        @variation_pct = 0
        @previous_entries = {}
      end
    end

    @chart_data = build_chart_data
  end

  private

  def build_chart_data
    return {} if @dashboard_data.empty?

    latest = @dashboard_data.last
    colors = chart_colors

    assets = Asset.active.by_position
    by_asset = assets.each_with_index.map do |asset, i|
      {
        label: asset.name,
        data: @dashboard_data.map { |d| (d[:by_asset_cents][asset.id] || 0) / 100.0 },
        borderColor: colors[i % colors.size]
      }
    end

    {
      dates: @dashboard_data.map { |d| d[:date].strftime("%d/%m/%Y") },
      totals: @dashboard_data.map { |d| d[:total_cents] / 100.0 },
      liquid_totals: @dashboard_data.map { |d| d[:liquid_total_cents] / 100.0 },
      by_asset: by_asset,
      by_category: latest[:by_category_cents].transform_values { |v| v / 100.0 },
      by_currency: latest[:by_currency_cents].transform_values { |v| v / 100.0 }
    }
  end
end
