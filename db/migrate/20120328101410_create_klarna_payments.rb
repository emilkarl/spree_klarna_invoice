class CreateKlarnaPayments < ActiveRecord::Migration
  def change
    create_table :spree_klarna_payments, :force => true do |t|
      t.string   :social_security_number, :invoice_number, :firstname, :lastname
      t.timestamps
    end
  end
end
