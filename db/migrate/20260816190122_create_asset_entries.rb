class CreateAssetEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :asset_entries do |t|
      t.references :snapshot, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.decimal :amount, null: false, default: 0, precision: 15, scale: 2
      t.decimal :dollar_rate, precision: 8, scale: 4

      t.timestamps
    end

    add_index :asset_entries, [ :snapshot_id, :asset_id ], unique: true
  end
end
