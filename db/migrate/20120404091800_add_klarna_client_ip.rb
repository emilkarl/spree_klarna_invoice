class AddKlarnaClientIp < ActiveRecord::Migration
  def change
    add_column :spree_klarna_payments, :client_ip, :string
  end
end