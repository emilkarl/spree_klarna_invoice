class Spree::KlarnaPayment < ActiveRecord::Base
  has_many :payments, :as => :source
  
  validates :social_security_number, :firstname, :lastname, :presence => true
  
  def actions
     %w{capture}
   end
   
   # Indicates whether its possible to capture the payment
   def can_capture?(payment)
     ['checkout', 'pending'].include?(payment.state) #&& payment.order.klarna_invoice_number.blank?
   end

   def payment_profiles_supported?
     true
   end

   def capture(payment)
     logger.info "\n\n\n------------------ CAPTURE ------------------\n"
     logger.info "Country Code #{payment.payment_method.preferred(:country_code)}"
     logger.info "Store Id #{payment.payment_method.preferred(:store_id)}"
     logger.info "Store Secret #{payment.payment_method.preferred(:store_secret)}"
     payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
     
     require 'klarna'
     
     Klarna::setup do |config|
       config.mode = :test
       config.country = payment.payment_method.preferred(:country_code) # SE
       config.store_id = payment.payment_method.preferred(:store_id) # 2029
       config.store_secret = payment.payment_method.preferred(:store_secret) # '3FPNSzybArL6vOg'
       config.logging = true
       config.http_logging = false
     end
     
     begin
       @@klarna = ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
     rescue Klarna::API::Errors::KlarnaCredentialsError => e
       logger.error e
     rescue ::Klarna::API::Errors::KlarnaServiceError => e
       gateway_error e.error_message
     end
     
     logger.info @@klarna.endpoint_uri.inspect
     
     test_pno = "411028-8083" # Not approved
     #test_pno = "410321-9202" # Approved
     
     # Implement verification to Klarna to get secret
     sso_secret = @@klarna.send(:digest, payment.payment_method.preferred(:store_id), test_pno, payment.payment_method.preferred(:store_secret))

     order_items = []
     
     # Add products
     payment.order.line_items.each do |item|
       logger.info "#{item.quantity}, #{item.product.sku}, #{item.product.name}, #{item.amount}, #{}"
       order_items << @@klarna.make_goods(item.quantity, item.product.sku, item.product.name, item.product.price * 100.00, 25, nil, ::Klarna::API::GOODS[:INC_VAT])
     end
     
     # Add shipment cost
     order_items << @@klarna.make_goods(1, I18n.t(:shipment), I18n.t(:shipment), payment.order.ship_total * 100.00, 25, nil, ::Klarna::API::GOODS[:INC_VAT])
     
     # Create address
     address = @@klarna.make_address("", payment.order.bill_address.address1, payment.order.bill_address.zipcode, payment.order.bill_address.city, payment.order.bill_address.country.iso, payment.order.bill_address.phone, nil, payment.order.email)
     
     # Do transaction and create invoice in Klarna
     begin
       invoice_no = @@klarna.add_transaction("USER-#{payment.order.user_id}", payment.order.number, order_items, 0, 0, :NORMAL, test_pno, payment.order.bill_address.firstname, payment.order.bill_address.lastname, address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)
     
       self.update_attribute(:invoice_number, invoice_no)
       logger.info "Invoice Nr: #{invoice_no}"
       logger.info "\n------------------ FINISHED CAPTURE ------------------\n\n\n"
       payment.complete
       true
     rescue ::Klarna::API::Errors::KlarnaServiceError => e
       raise Spree::Core::GatewayError.new e.error_message
     end
   end
end
