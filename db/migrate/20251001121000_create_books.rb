class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title, null: false
      t.text :resume
      t.decimal :rating, precision: 2, scale: 1, null: false, default: 0.0
      t.string :status, null: false, default: "tbr"
      t.date :date_started
      t.date :date_finished
      t.text :review

      t.timestamps
    end

    add_index :books, :status
  end
end
