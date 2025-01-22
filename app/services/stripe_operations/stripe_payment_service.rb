# used in the order controller

module StripeOperations
  class StripePaymentService
    def initialize(product, stripe_token, order_params = nil)
      @product = product
      @stripe_token = stripe_token
      @order_params = order_params
    end

    def process_payment
      charge_service = StripeOperations::StripeChargeService.new(@product, @stripe_token)
      charge = charge_service.process_payment
      if charge.status == 'succeeded'
        @product.reduce_stripe_quantity
      end
      charge
    rescue Stripe::CardError => e
      raise e.message
    end

    def create_order_and_process_payment
      Orders::OrderParamsValidator.validate(@order_params)
      order_service = Orders::OrderService.new(@product, @order_params, @stripe_token)
      order = order_service.create_order
      process_payment if order.persisted?
      order
    end
  end
end
