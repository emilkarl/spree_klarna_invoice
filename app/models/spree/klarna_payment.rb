class Spree::KlarnaPayment < ActiveRecord::Base
  has_many :payments, :as => :source

  validates :social_security_number, :firstname, :lastname, :presence => true
  
  attr_accessible :firstname, :lastname, :social_security_number, :invoice_number
  
  def actions
    %w{capture}
  end

  # Indicates whether its possible to capture the payment
  def can_capture?(payment)
    ['checkout', 'pending', 'processing'].include?(payment.state) && !payment.order.klarna_invoice_number.blank?
  end

  def process!(payment)
    logger.debug "\n----------- KlarnaPayment.process! -----------\n"
    create_invoice(payment)
    capture(payment) if Spree::Config[:auto_capture]
  end
  
  # Activate action
  def capture(payment)
    logger.debug "\n----------- KlarnaPayment.activate -----------\n"
    logger.info "Country Code #{payment.payment_method.preferred(:country_code)}"
    logger.info "Store Id #{payment.payment_method.preferred(:store_id)}"
    logger.info "Store Secret #{payment.payment_method.preferred(:store_secret)}"
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout' || payment.state == 'processing'

    begin
      activate_invoice(payment) if payment.payment_method.preferred(:mode) != "test"
      payment.complete
      true 
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      gateway_error(e.error_message)
    end
  end
  
  private
  
  # Init Klarna instance
  def init_klarna(payment)
    @@klarna ||= setup_klarna(payment)
  end
  
  # Setup Klarna connection
  def setup_klarna(payment)
    logger.debug "\n----------- KlarnaPayment.setup_klarna -----------\n"
    require 'klarna'

    Klarna::setup do |config|
      config.mode = payment.payment_method.preferred(:mode)
      config.country = payment.payment_method.preferred(:country_code) # SE
      config.store_id = payment.payment_method.preferred(:store_id) # 2029
      config.store_secret = payment.payment_method.preferred(:store_secret) # '3FPNSzybArL6vOg'
      config.logging = payment.payment_method.preferred(:logging)
      config.http_logging = payment.payment_method.preferred(:http_logging)
    end

    begin
      return ::Klarna::API::Client.new(::Klarna.store_id, ::Klarna.store_secret)
    rescue Klarna::API::Errors::KlarnaCredentialsError => e
      gateway_error(e.error_message)
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      gateway_error(e.error_message)
    end
  end
  
  # Create Klarna invoice and send to 
  def create_invoice(payment)
    logger.debug "\n----------- KlarnaPayment.create_invoice -----------\n"
    
    # Initialize Klarna connection
    init_klarna(payment)
    
    #test_pno = "411028-8083" # Not approved
    ssn = "410321-9202" # Approved - Should be taken from self.social_security_number later on...

    # Implement verification to Klarna to get secret
    sso_secret = @@klarna.send(:digest, payment.payment_method.preferred(:store_id), ssn, payment.payment_method.preferred(:store_secret))
    logger.debug "\n----------- SSO Secret #{sso_secret} for #{ssn} -----------\n"
    order_items = []

    # Add products
    payment.order.line_items.each do |item|
      logger.debug "\n----------- Item: #{item.quantity}, #{item.product.sku}, #{item.product.name}, #{item.amount} -----------\n"
      order_items << @@klarna.make_goods(item.quantity, item.product.sku, item.product.name, item.product.price * 100.00, 25, nil, ::Klarna::API::GOODS[:INC_VAT])
    end

    # Add shipment cost
    #order_items << @@klarna.make_goods(1, I18n.t(:shipment), I18n.t(:shipment), payment.order.ship_total * 100.00, 25, nil, ::Klarna::API::GOODS[:INC_VAT])

    # Create address
    address = @@klarna.make_address("", payment.order.bill_address.address1, payment.order.bill_address.zipcode, payment.order.bill_address.city, payment.order.bill_address.country.iso, payment.order.bill_address.phone, nil, payment.order.email)

    # Do transaction and create invoice in Klarna
    begin
      logger.debug "\n----------- add_transaction -----------\n"
      shipping_cost = payment.order.ship_total * 100
      invoice_no = @@klarna.add_transaction(
          "USER-#{payment.order.user_id}",                            # store_user_id,
          payment.order.number,                                       # order_id,
          order_items,                                                # articles,
          shipping_cost.to_i,                                         # shipping_fee,
          0,                                                          # handling_fee,
          :NORMAL,                                                    # shipment_type,
          ssn,                                                        # pno,
          payment.order.bill_address.firstname,                       # first_name,
          payment.order.bill_address.lastname,                        # last_name,
          address,                                                    # address,
          '85.230.98.196',                                            # client_ip,
          :SEK,           # currency, 
          :SE,            # country, 
          :SV,            # language, 
          :SE)            # pno_encoding, 
                                                                  # pclass = nil, 
                                                                  # annual_salary = nil,
                                                                  # password = nil, 
                                                                  # ready_date = nil, 
                                                                  # comment = nil, 
                                                                  # rand_string = nil, 
                                                                    # flags = nil
                                                                       
      logger.debug "\n----------- Invoice: #{invoice_no} -----------\n"                                                             
      self.update_attribute(:invoice_number, invoice_no)
    rescue ::Klarna::API::Errors::KlarnaServiceError => e
      gateway_error(e.error_message)
    end
  end
  
  # Active Klarna Invoice
  def activate_invoice(payment)
    logger.debug "\n----------- KlarnaPayment.activate_invoice -----------\n"
    init_klarna(payment)
    @@klarna.activate_invoice(self.invoice_number)
  end
  
  def gateway_error(text)
    msg = "#{I18n.t(:gateway_error)} ... #{text}"
    logger.error(msg)
    raise Spree::Core::GatewayError.new(msg)
  end
end
