class CreateRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :records do |t|
      t.references :series, null: false, foreign_key: true
      t.date :played_date, null: false
      t.integer :price_per_play, null: false
      t.integer :play_count, null: false
      t.timestamps
    end
    add_check_constraint :records, "price_per_play > 0", name: "records_price_per_play_positive"
    add_check_constraint :records, "play_count > 0", name: "records_play_count_positive"
  end
end
