Spree::Order.class_eval do
  def set_error(message)
    @@e_message = message
  end
  
  def get_error
    (@@e_message.nil? || @@e_message.blank?) ? I18n.t(:payment_processing_failed) : @@e_message
  end
  
  def update_adjustment_tax
    logger.debug "\n\n---------- #{adjustments.eligible} ----------\n\n"
    (adjustments.eligible - adjustments.tax - adjustments.shipping).each do |adjustment|
      logger.debug "\n\n---------- #{adjustment.label} ----------\n\n"
      adjustment.adjustments.each { |a| a.destroy }
    
      default_tax_rate = Spree::TaxRate.find(1)
    
      adjustment_amount = (adjustment.amount - (adjustment.amount / (1+default_tax_rate.amount)))
      target = adjustment
    
      label = "#{default_tax_rate.tax_category.name} #{default_tax_rate.amount * 100}%"
    
      if not default_tax_rate.included_in_price
        adjustment_amount = ((adjustment.amount * (1+default_tax_rate.amount)) - adjustment.amount)
        target = self
      end
    
      target.adjustments.create(:amount => adjustment_amount,
                                :source => adjustment,
                                :originator => default_tax_rate,
                                :locked => true,
                                :label => "#{label}")
    end
  end
end