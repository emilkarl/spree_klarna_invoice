class Spree::KlarnaPayment < ActiveRecord::Base
  has_many :payments, :as => :source

  def actions
    %w{capture}
  end

  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    ['checkout', 'pending'].include?(payment.state) #&& payment.order.klarna_invoice_number.blank?
  end

  def capture(payment)
    logger.info "\n\n\n------------------ CAPTURE ------------------\n"
    logger.info "Country Code #{self.preferred(:country_code)}"
    logger.info "Store Id #{self.preferred(:store_id)}"
    logger.info "Store Secret #{self.preferred(:store_secret)}"
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout'

    require 'klarna'

    Klarna::setup do |config|
      config.mode = :test
      config.country = self.preferred(:country_code) # SE
      config.store_id = self.preferred(:store_id) # 2029
      config.store_secret = self.preferred(:store_secret) # '3FPNSzybArL6vOg'
      config.logging = true
      config.http_logging = false
    end

    begin
      @@klarna = ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
    rescue Klarna::API::Errors::KlarnaCredentialsError => e
      logger.error e
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      logger.error e
    end

    logger.info @@klarna.endpoint_uri.inspect

    logger.info ::Klarna::API::PNO_FORMATS[:SE].inspect

    logger.info "SSN: "
    test_pno = "411028-8083" # Not approved
    #test_pno = "410321-9202" # Approved

    # Implement verification to Klarna to get secret
    #sso_secret = @@klarna.send(:digest, self.preferred(:store_id), test_pno, self.preferred(:store_secret))
    #logger.info "SSO Secret: #{sso_secret}"

    logger.info "#{payment.order.bill_address.firstname} #{payment.order.bill_address.lastname}"

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

    begin
      invoice_no = @@klarna.add_transaction("USER-#{payment.order.user_id}", payment.order.number, order_items, 0, 0, :NORMAL, test_pno, payment.order.bill_address.firstname, payment.order.bill_address.lastname, address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)

      payment.order.update_attribute(:klarna_invoice_number, invoice_no)
      logger.info "Invoice Nr: #{invoice_no}"
      logger.info "\n------------------ FINISHED CAPTURE ------------------\n\n\n"
      payment.complete
      true
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      gateway_error e.error_message
    end


    # puts @@klarna.get_addresses(test_pno, ::Klarna::API::PNO_FORMATS[:SE])
    # ----------------------
    # order_items = []
    # # (quantity, article_no, title, price, vat, discount = nil, flags = nil)
    # order_items << @@klarna.make_goods(1, "ABC1", "T-shirt 1", 1.00 * 100, 25)
    # order_items << @@klarna.make_goods(1, "ABC2", "T-shirt 2", 7.00 * 100, 25)
    # order_items << @@klarna.make_goods(1, "ABC3", "T-shirt 3", 17.00 * 100, 25)
    # 


    # # invoice_no = @@klarna.add_transaction("USER-#{test_pno}", 'ORDER-1', order_items, 0, 0, :NORMAL, test_pno, "Karl", "Lidin", address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)
    # invoice_no = @@klarna.add_transaction("USER-#{test_pno}", 'MY ORDER', order_items, 0, 0, :NORMAL, test_pno, "Jonas", "Grimfelt", address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)
    # 
    # pp "Invoice-no: #{invoice_no}"


    #payment.complete
    #true
  end
  
  def gateway_error(text)
    msg = "#{I18n.t('gateway_error')} ... #{text}"
    logger.error(msg)
    raise Spree::GatewayError.new(msg)
  end
end
