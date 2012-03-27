class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :country_code, :string, :default => 'SE'
  preference :store_id, :integer
  preference :store_sectret, :string
  
  def actions
    %w{capture void}
  end
  
  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    ['checkout', 'pending'].include?(payment.state)
  end
  
  def capture(payment)
    logger.info payment
    
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
    payment.complete
    true
  end
  
  def payment_source_class
    Spree::KlarnaCustomer
  end
end


