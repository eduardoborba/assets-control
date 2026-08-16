class AssetEntry < ApplicationRecord
  belongs_to :snapshot
  belongs_to :asset

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :snapshot_id, uniqueness: { scope: :asset_id, message: "already has an entry for this asset" }
  validate :dollar_rate_required_for_usd_assets

  def value_in_brl
    return amount if asset.brl?
    return 0 unless dollar_rate.present?

    amount * dollar_rate
  end

  private

  def dollar_rate_required_for_usd_assets
    return unless asset&.usd? && dollar_rate.blank?

    errors.add(:dollar_rate, "is required for USD assets")
  end
end
