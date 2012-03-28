class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :country_code, :string, :default => 'SE'
  preference :store_id, :integer
  preference :store_secret, :string
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::KlarnaPayment
  end
end


