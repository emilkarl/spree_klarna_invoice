Spree::BaseHelper.class_eval do
  def get_client_ip
    request.remote_ip
  end
  
  def pnr_validation_error(min, max)
    if(min != max) 
      "#{I18n.t(:pnr_validation_first)} #{I18n.t(:between)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_min)} #{I18n.t(:and)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_max)} #{I18n.t(:chars)}. #{I18n.t(:pnr_formats)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_formats)}"
    else
      "#{I18n.t(:pnr_validation_first)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_min)} #{I18n.t(:chars)}. #{I18n.t(:pnr_formats)} #{Spree::PaymentMethod::KlarnaInvoice.first.preferred(:pnr_formats)}"
    end
  end
end