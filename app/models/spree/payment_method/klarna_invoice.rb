class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :country_code, :string, :default => 'SE' 
  preference :currency_code, :string, :default => 'SEK'
  preference :language_code, :string, :default => 'SV'
  preference :store_id, :integer # 2029
  preference :store_secret, :string # 3FPNSzybArL6vOg
  preference :mode, :string, :default => :test # live
  preference :logging, :boolean, :default => true
  preference :http_logging, :boolean, :default => false
  preference :invoice_fee, :integer, :default => 70
  preference :activate_in_days, :integer, :default => 0
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::KlarnaPayment
  end
end


