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

  def chart_colors
    [
      "#2563eb", "#16a34a", "#ea580c", "#9333ea", "#dc2626",
      "#0891b2", "#ca8a04", "#be185d", "#6b7280"
    ]
  end

  def variation_arrow(delta)
    if delta >= 0
      '<svg class="inline-block w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18"></path></svg>'.html_safe
    else
      '<svg class="inline-block w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"></path></svg>'.html_safe
    end
  end
end
