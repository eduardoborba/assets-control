class Snapshot < ApplicationRecord
  has_many :asset_entries, dependent: :destroy
  accepts_nested_attributes_for :asset_entries, reject_if: :all_blank

  validates :taken_on, presence: true, uniqueness: true

  scope :chronological, -> { order(:taken_on) }
  scope :recent_first, -> { order(taken_on: :desc) }

  def previous
    self.class.where("taken_on < ?", taken_on).chronological.last
  end

  def total_brl_cents
    asset_entries.sum { |entry| entry.value_in_brl_cents }
  end

  def liquid_total_brl_cents
    asset_entries.joins(:asset).where(assets: { liquid: true }).sum { |entry| entry.value_in_brl_cents }
  end

  def total_brl
    total_brl_cents / 100.0
  end

  def liquid_total_brl
    liquid_total_brl_cents / 100.0
  end
end
