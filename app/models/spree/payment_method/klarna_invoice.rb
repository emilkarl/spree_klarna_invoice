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
    # Implement verification to Klarna to get secret
    # sso_secret = @@klarna.send(:digest, payment.store_id, payment.sso, payment.store_secret)
    # puts @@klarna.get_addresses(test_pno, ::Klarna::API::PNO_FORMATS[:SE])
    # ----------------------
    # order_items = []
    # order_items << @@klarna.make_goods(1, "ABC1", "T-shirt 1", 1.00 * 100, 25)
    # order_items << @@klarna.make_goods(1, "ABC2", "T-shirt 2", 7.00 * 100, 25)
    # order_items << @@klarna.make_goods(1, "ABC3", "T-shirt 3", 17.00 * 100, 25)
    # 
    # #address = @@klarna.make_address("", "Junibackg. 42", "23634", "Hollviken", :SE, "076 526 00 00", "076 526 00 00", "karl.lidin@klarna.com")

    # # invoice_no = @@klarna.add_transaction("USER-#{test_pno}", 'ORDER-1', order_items, 0, 0, :NORMAL, test_pno, "Karl", "Lidin", address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)
    # invoice_no = @@klarna.add_transaction("USER-#{test_pno}", 'MY ORDER', order_items, 0, 0, :NORMAL, test_pno, "Jonas", "Grimfelt", address, '85.230.98.196', :SEK, :SE, :SV, :SE) #, nil, nil, nil, nil, nil, nil, nil, :TEST_MODE => true)
    # 
    # pp "Invoice-no: #{invoice_no}"
    
    payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
    payment.complete
    true
  end
end


