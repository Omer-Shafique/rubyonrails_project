# used in the stripe payment service which is called in the order controller

module Orders
  class OrderService
    def initialize(user, product, order_params, stripe_token = nil)
      @user = user
      @product = product
      @order_params = order_params
      @stripe_token = stripe_token
    end
    
    def create_order
      raise "Order params are missing" unless @order_params
      customer = create_stripe_customer
      order = build_order(customer)
      if order.save
        order
      else
        raise StandardError, "Failed to create order."
      end
    end

    def create_or_fetch_order
      order = Order.find_by(product_id: @product.id, user_id: @user.id)

      if order.nil?
        order = build_order
        charge_and_create_customer(order)
      end

      order
    end

    private


    def build_order(customer)
      Order.new(
        product: @product,
        customer_name: @order_params[:name],
        customer_email: @order_params[:email],
        customer_address: @order_params[:address],
        customer_phone: @order_params[:phone],
        stripe_customer_id: customer.id
      )
    end

    def charge_and_create_customer(order)
      return unless @stripe_token
      charge_service = StripeOperations::StripeChargeService.new(@product, @stripe_token)
      charge = charge_service.process_payment
      if charge.status == 'succeeded' && order.save
        create_stripe_customer(order)
      else
        raise StandardError, "Payment processing failed."
      end
    end

    private

    def create_stripe_customer(order)
      customer = Stripe::Customer.create(
        #tbd
        # name: @order_params[:name],
        email: @order_params[:email],
        address: @order_params[:address],
        phone: @order_params[:phone],
        source: @stripe_token
      )

      order.update(stripe_customer_id: customer.id)
    end
  end
end
