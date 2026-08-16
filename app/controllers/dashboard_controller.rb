class DashboardController < ApplicationController
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
      else
        @variation_cents = 0
        @variation_pct = 0
      end
    end

    @chart_data = build_chart_data
  end

  private

  def build_chart_data
    return {} if @dashboard_data.empty?

    latest = @dashboard_data.last
    {
      dates: @dashboard_data.map { |d| d[:date].strftime("%d/%m/%Y") },
      totals: @dashboard_data.map { |d| d[:total_cents] / 100.0 },
      liquid_totals: @dashboard_data.map { |d| d[:liquid_total_cents] / 100.0 },
      by_category: latest[:by_category_cents].transform_values { |v| v / 100.0 },
      by_currency: latest[:by_currency_cents].transform_values { |v| v / 100.0 }
    }
  end
end
