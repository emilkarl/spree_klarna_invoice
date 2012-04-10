Spree::BaseHelper.class_eval do
  def get_client_ip
    request.remote_ip
  end
end