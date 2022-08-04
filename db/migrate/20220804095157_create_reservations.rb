class CreateReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :reservations do |t|
      t.integer :tickets_count
      t.belongs_to :ticket, null: false, foreign_key: true
      t.boolean :purchased_status, null: false, default: false

      t.timestamps
    end
  end
end
