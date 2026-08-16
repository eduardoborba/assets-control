class DashboardService
  def initialize(base_currency: "BRL")
    @base_currency = base_currency
  end

  def call
    snapshots = Snapshot.chronological.includes(asset_entries: :asset)

    snapshots.map do |snapshot|
      {
        date: snapshot.taken_on,
        total: total_brl(snapshot),
        liquid_total: liquid_total_brl(snapshot),
        by_category: by_category(snapshot),
        by_currency: by_currency(snapshot)
      }
    end
  end

  private

  def total_brl(snapshot)
    snapshot.asset_entries.sum { |entry| entry.value_in_brl }
  end

  def liquid_total_brl(snapshot)
    snapshot.asset_entries.select { |e| e.asset.liquid? }.sum { |entry| entry.value_in_brl }
  end

  def by_category(snapshot)
    snapshot.asset_entries
      .group_by { |e| e.asset.category }
      .transform_values { |entries| entries.sum { |e| e.value_in_brl } }
  end

  def by_currency(snapshot)
    snapshot.asset_entries
      .group_by { |e| e.asset.currency }
      .transform_values { |entries| entries.sum { |e| e.value_in_brl } }
  end
end
