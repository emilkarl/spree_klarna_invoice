class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :store_id, :integer # 2029
  preference :store_secret, :string # 3FPNSzybArL6vOg
  preference :mode, :string, :default => :test # live
  preference :invoice_fee, :integer, :default => 70
  preference :auto_activate, :boolean, :default => false
  preference :activate_in_days, :integer, :default => 0
  preference :email_invoice, :boolean, :default => true
  preference :send_invoice, :boolean, :default => false
  preference :country_code, :string, :default => 'SE' 
  preference :currency_code, :string, :default => 'SEK'
  preference :language_code, :string, :default => 'SV'
  preference :logging, :boolean, :default => true
  preference :http_logging, :boolean, :default => false
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::KlarnaPayment
  end
end


