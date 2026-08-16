class AssetEntry < ApplicationRecord
  RATE_SCALE = 10_000

  belongs_to :snapshot
  belongs_to :asset

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :snapshot_id, uniqueness: { scope: :asset_id, message: "already has an entry for this asset" }
  validate :dollar_rate_required_for_usd_assets

  def value_in_brl_cents
    return amount if asset.brl?
    return 0 unless dollar_rate.present?

    (amount * dollar_rate) / RATE_SCALE
  end

  def amount_reais
    amount / 100.0
  end

  def dollar_rate_reais
    return nil unless dollar_rate.present?

    dollar_rate / RATE_SCALE.to_f
  end

  private

  def dollar_rate_required_for_usd_assets
    return unless asset&.usd? && dollar_rate.blank?

    errors.add(:dollar_rate, "is required for USD assets")
  end
end
