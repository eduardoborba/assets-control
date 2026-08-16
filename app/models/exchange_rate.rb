class ExchangeRate < ApplicationRecord
  validates :base_currency, presence: true, length: { is: 3 }
  validates :quote_currency, presence: true, length: { is: 3 }
  validates :rate, presence: true, numericality: { greater_than: 0 }
  validates :fetched_on, presence: true
  validates :base_currency, uniqueness: { scope: [ :quote_currency, :fetched_on ] }

  scope :for_pair, ->(base, quote) { where(base_currency: base, quote_currency: quote) }
  scope :on_date, ->(date) { where(fetched_on: date) }
  scope :latest_first, -> { order(fetched_on: :desc) }

  def self.find_rate(base:, quote:, on_date:)
    where(base_currency: base, quote_currency: quote)
      .where("fetched_on <= ?", on_date)
      .latest_first
      .first
  end
end
