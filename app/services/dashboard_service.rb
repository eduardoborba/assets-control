class DashboardService
  def initialize(base_currency: "BRL")
    @base_currency = base_currency
  end

  def call
    snapshots = Snapshot.chronological.includes(asset_entries: :asset)

    snapshots.map do |snapshot|
      {
        date: snapshot.taken_on,
        total_cents: total_brl_cents(snapshot),
        liquid_total_cents: liquid_total_brl_cents(snapshot),
        by_category_cents: by_category_cents(snapshot),
        by_currency_cents: by_currency_cents(snapshot),
        by_asset_cents: by_asset_cents(snapshot)
      }
    end
  end

  private

  def total_brl_cents(snapshot)
    snapshot.asset_entries.sum { |entry| entry.value_in_brl_cents }
  end

  def liquid_total_brl_cents(snapshot)
    snapshot.asset_entries.select { |e| e.asset.liquid? }.sum { |entry| entry.value_in_brl_cents }
  end

  def by_category_cents(snapshot)
    snapshot.asset_entries
      .group_by { |e| e.asset.category }
      .transform_values { |entries| entries.sum { |e| e.value_in_brl_cents } }
  end

  def by_currency_cents(snapshot)
    snapshot.asset_entries
      .group_by { |e| e.asset.currency }
      .transform_values { |entries| entries.sum { |e| e.value_in_brl_cents } }
  end

  def by_asset_cents(snapshot)
    snapshot.asset_entries.each_with_object({}) do |entry, hash|
      hash[entry.asset_id] = entry.value_in_brl_cents
    end
  end
end
