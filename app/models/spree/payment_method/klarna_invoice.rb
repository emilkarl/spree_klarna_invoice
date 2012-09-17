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
  preference :timeout, :integer, :default => 10
  preference :pnr_formats, :string, :default => 'YYMMDD-NNNN, YYMMDDNNNN'
  preference :pnr_min, :integer, :default => 8
  preference :pnr_max, :integer, :default => 10
  
  attr_accessible :store_id, :store_secret, :mode, :invoice_fee, :auto_activate, :activate_in_days, :email_invoice, :send_invoice, :country_code, :language_code, :logging, :http_logging, :timeout, :preferred_store_id, :preferred_store_secret, :preferred_mode, :preferred_invoice_fee, :preferred_auto_activate, :preferred_activate_in_days, :preferred_email_invoice, :preferred_send_invoice, :preferred_country_code, :preferred_language_code, :preferred_logging, :preferred_http_logging, :preferred_timeout, :preferred_currency_code, :preferred_pnr_formats, :preferred_pnr_min, :preferred_pnr_max
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::KlarnaPayment
  end
  
  def payment_profiles_supported?
    true
  end
end


