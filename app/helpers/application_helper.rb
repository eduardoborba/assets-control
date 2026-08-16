module ApplicationHelper
  def brl_currency(cents)
    number_to_currency(cents / 100.0, unit: "R$", separator: ",", delimiter: ".")
  end

  def brl_amount(cents)
    number_with_precision(cents / 100.0, precision: 2, separator: ",", delimiter: ".")
  end

  def brl_rate(cents)
    number_with_precision(cents / 10_000.0, precision: 4, separator: ",", delimiter: ".")
  end
end
