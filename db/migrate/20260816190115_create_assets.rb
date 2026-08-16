class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :currency, null: false, limit: 3
      t.boolean :liquid, null: false, default: true
      t.boolean :archived, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :assets, :category
    add_index :assets, :archived
  end
end
