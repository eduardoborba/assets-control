class EntryValueService
  RATE_SCALE = ExchangeRate::RATE_SCALE

  def initialize(asset_entry)
    @asset_entry = asset_entry
    @asset = asset_entry.asset
  end

  def call
    return @asset_entry.amount if @asset.brl?
    return 0 unless @asset_entry.dollar_rate.present?

    (@asset_entry.amount * @asset_entry.dollar_rate) / RATE_SCALE
  end
end
