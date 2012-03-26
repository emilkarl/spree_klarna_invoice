class CreateKlarnaCustomer < ActiveRecord::Migration
  def change
    create_table :spree_klarna_customers do |t|
      t.integer :sso
      t.string :first_name, :last_name, :city

      t.timestamps
    end
  end
end
