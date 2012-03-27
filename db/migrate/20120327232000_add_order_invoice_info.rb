class AddOrderInvoiceInfo < ActiveRecord::Migration
  def change
    add_column :spree_orders, :social_security_number, :string
    add_column :spree_orders, :klarna_invoice_number, :string
  end
end