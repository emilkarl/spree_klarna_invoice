class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :country_code, :integer, :default => 'SE' 
  preference :currency_code, :integer, :default => 'SEK'
  preference :language_code, :integer, :default => 'SV'
  preference :store_id, :integer
  preference :store_secret, :string
  preference :mode, :string, :default => :test
  preference :logging, :boolean, :default => true
  preference :http_logging, :boolean, :default => false
  preference :invoice_fee, :integer, :default => 70
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::KlarnaPayment
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


