class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.string :make
      t.string :model
      t.integer :year
      t.decimal :price
      t.integer :mileage
      t.string :color
      t.string :stock_no
      t.text :description
      t.boolean :featured

      t.timestamps
    end
  end
end
