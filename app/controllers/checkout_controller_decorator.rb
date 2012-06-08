Spree::CheckoutController.class_eval do
  before_filter :set_klarna_client_ip, :only => [:update]
  
  # Updates the order and advances to the next state (when possible.)
  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')
      
      # Promo starts
      if @order.coupon_code.present?

        if Spree::Promotion.exists?(:code => @order.coupon_code)
          fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
          # If it doesn't exist, raise an error!
          # Giving them another chance to enter a valid coupon code
        else
          flash[:error] = t(:promotion_not_found)
          render :edit and return
        end
      end
      # Promo ends
       
      if @order.next
        state_callback(:after)
      else
        flash[:error] = @order.get_error 
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