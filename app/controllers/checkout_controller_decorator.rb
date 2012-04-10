Spree::CheckoutController.class_eval do
  before_filter :set_klarna_client_ip, :only => [:update]
  
  def set_klarna_client_ip
    @client_ip = request.remote_ip # Set client ip
  end
end