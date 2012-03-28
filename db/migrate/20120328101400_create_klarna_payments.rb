class CreateKlarnaPayments < ActiveRecord::Migration
  def change
    create_table :spree_klarna_payments, :force => true do |t|
      t.string   :invoice_number
      t.timestamps
    end
  end
end
