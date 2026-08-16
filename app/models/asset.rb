class Asset < ApplicationRecord
  has_many :asset_entries, dependent: :restrict_with_error

  enum :category, {
    stocks: "stocks",
    fixed_income: "fixed_income",
    real_estate: "real_estate",
    vehicle: "vehicle",
    insurance: "insurance",
    bank_account: "bank_account",
    other: "other"
  }

  validates :name, presence: true
  validates :category, presence: true
  validates :currency, presence: true, length: { is: 3 }
  validates :position, numericality: { only_integer: true }

  scope :active, -> { where(archived: false) }
  scope :liquid, -> { where(liquid: true) }
  scope :by_position, -> { order(:position) }

  def brl?
    currency == "BRL"
  end

  def usd?
    currency == "USD"
  end
end
