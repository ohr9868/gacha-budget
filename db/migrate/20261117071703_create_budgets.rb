class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.date :month, null: false
      t.integer :amount, null: false
      t.timestamps
    end
    add_index :budgets, [ :user_id, :month ], unique: true
    add_check_constraint :budgets, "amount >= 0", name: "budgets_amount_non_negative"
    add_check_constraint :budgets, "EXTRACT(DAY FROM month) = 1", name: "budgets_month_first_day"
  end
end
