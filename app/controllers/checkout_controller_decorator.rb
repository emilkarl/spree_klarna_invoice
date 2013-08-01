Spree::CheckoutController.class_eval do
  before_filter :set_klarna_client_ip, :only => [:update]
  
  # Updates the order and advances to the next state (when possible.)
  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')
      
      unless apply_coupon_code
        respond_with(@order) { |format| format.html { render :edit } }
        return
      end

      # Add Klarna invoice cost
      if @order.payments.exists? && @order.adjustments.klarna_invoice_cost.count <= 0 && @order.payments.first.payment_method && @order.payments.first.payment_method.class.name == 'Spree::PaymentMethod::KlarnaInvoice'
        @order.adjustments.create(:amount => @order.payments.first.payment_method.preferred(:invoice_fee),
                                  :source => @order,
                                  :originator => @order.payments.first.payment_method,
                                  :locked => true,
                                  :label => I18n.t(:invoice_fee))
        @order.update!
      end
      
      # Remove Klarna invoice cost
      if @order.payments.exists? && @order.adjustments.klarna_invoice_cost.count > 0 && @order.payments.first.payment_method && @order.payments.first.payment_method.class.name != 'Spree::PaymentMethod::KlarnaInvoice'
        @order.adjustments.klarna_invoice_cost.destroy_all
        @order.update!
      end
      
      if @order.next
        state_callback(:after)
      else
        flash[:error] = @order.get_error # Changed by Noc
        respond_with(@order, :location => checkout_state_path(@order.state))
        return
      end

      if @order.state == "complete" || @order.completed?
        flash.notice = t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        respond_with(@order, :location => completion_route)
      else
        respond_with(@order, :location => checkout_state_path(@order.state))
      end
    else
      respond_with(@order) { |format| format.html { render :edit } }
    end
  end
  
  def set_klarna_client_ip
    @client_ip = request.remote_ip # Set client ip
  end
end