Spree::Order.class_eval do
  def set_error(message)
    logger.debug "\n--------------------------------------------------------\nError message:#{message}\n----------------------------\n"
    @@e_message = message
  end
  
  def get_error
    @@e_message.blank? ? I18n.t(:payment_processing_failed) : @@e_message
  end
end