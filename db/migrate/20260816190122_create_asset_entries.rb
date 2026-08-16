class CreateAssetEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :asset_entries do |t|
      t.references :snapshot, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.bigint :amount, null: false, default: 0
      t.bigint :dollar_rate

      t.timestamps
    end

    add_index :asset_entries, [ :snapshot_id, :asset_id ], unique: true
  end
end
