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
  
  def payment_profiles_supported?
    false
  end
  
  def actions
    %w{capture}
  end
  
  # Indicates whether its possible to capture the payment
   def can_capture?(payment)
     ['checkout', 'pending'].include?(payment.state) #&& payment.order.klarna_invoice_number.blank?
   end
   
   def capture(payment)
     logger.info "\n\n\n------------------ CAPTURE ------------------\n"
     payment.complete
     true
   end
end


