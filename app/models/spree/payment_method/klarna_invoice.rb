class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :country_code, :string, :default => 'SE'
  preference :store_id, :integer
  preference :store_secret, :string
  
  def actions
    %w{capture}
  end
  
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


