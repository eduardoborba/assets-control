class Snapshot < ApplicationRecord
  has_many :asset_entries, dependent: :destroy

  validates :taken_on, presence: true, uniqueness: true

  scope :chronological, -> { order(:taken_on) }
  scope :recent_first, -> { order(taken_on: :desc) }

  def previous
    self.class.where("taken_on < ?", taken_on).chronological.last
  end

  def total_brl
    asset_entries.sum { |entry| entry.value_in_brl }
  end

  def liquid_total_brl
    asset_entries.joins(:asset).where(assets: { liquid: true }).sum { |entry| entry.value_in_brl }
  end
end
