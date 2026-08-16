puts "Seeding database..."

assets_data = [
  { name: "ETFs gringos", category: "stocks", currency: "USD", liquid: true },
  { name: "DOCS", category: "stocks", currency: "USD", liquid: true },
  { name: "Ações/FII", category: "stocks", currency: "BRL", liquid: true },
  { name: "Conta corrente", category: "bank_account", currency: "BRL", liquid: true },
  { name: "Renda fixa", category: "fixed_income", currency: "BRL", liquid: true },
  { name: "Seguro Warren", category: "insurance", currency: "BRL", liquid: false },
  { name: "Conta PJ", category: "bank_account", currency: "BRL", liquid: false },
  { name: "Apartamento", category: "real_estate", currency: "BRL", liquid: false },
  { name: "Carro", category: "vehicle", currency: "BRL", liquid: false }
]

assets = assets_data.map do |data|
  Asset.find_or_create_by!(name: data[:name]) do |a|
    a.category = data[:category]
    a.currency = data[:currency]
    a.liquid = data[:liquid]
    a.position = assets_data.index(data) + 1
  end
end

puts "Created #{assets.size} assets"
