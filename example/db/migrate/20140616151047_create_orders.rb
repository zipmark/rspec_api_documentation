class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :name
      t.boolean :paid
      t.string :email

      t.timestamps
    end
  end
end
