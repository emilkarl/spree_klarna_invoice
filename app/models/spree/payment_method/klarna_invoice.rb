class Spree::PaymentMethod::KlarnaInvoice < Spree::PaymentMethod
  preference :country_code, :string, :default => 'SE'
  preference :store_id, :integer
  preference :store_secret, :string
  
  def actions
    %w{capture}
  end
  
  def require_source?
    false
  end
  
  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    ['checkout', 'pending'].include?(payment.state) #&& payment.order.klarna_invoice_number.blank?
  end

  def capture(payment)
    logger.info "\n\n\n------------------ CAPTURE ------------------\n"
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
    payment.complete
    true
  end
end


