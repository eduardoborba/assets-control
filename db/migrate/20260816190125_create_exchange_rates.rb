class CreateExchangeRates < ActiveRecord::Migration[8.1]
  def change
    create_table :exchange_rates do |t|
      t.string :base_currency, null: false, limit: 3
      t.string :quote_currency, null: false, limit: 3
      t.decimal :rate, null: false, precision: 12, scale: 6
      t.date :fetched_on, null: false

      t.timestamps
    end

    add_index :exchange_rates, [ :base_currency, :quote_currency, :fetched_on ], unique: true, name: "index_exchange_rates_on_currencies_and_date"
  end
end
