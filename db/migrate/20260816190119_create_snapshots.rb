class CreateSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :snapshots do |t|
      t.date :taken_on, null: false
      t.text :notes

      t.timestamps
    end

    add_index :snapshots, :taken_on, unique: true
  end
end
