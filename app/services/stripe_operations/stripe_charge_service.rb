# used in the stripe payment service which is called in the order controller

module StripeOperations
  class StripeChargeService
    def initialize(product, stripe_token)
      @product = product
      @stripe_token = stripe_token
    end

    #tbd
    def process_payment #tbd
      charge = Stripe::Charge.create(
        amount: (@product.price * 100).to_i,
        currency: 'usd',
        source: @stripe_token,
        description: "Charging for product #{@product.product_title}",
        receipt_email: @user_email,
        metadata: { "Name" => @user_name, "Email" => @user_email, "Product Image" => image_url }
      )

      if charge.status == 'succeeded'
        @product.reduce_stripe_quantity
      end

      charge
    rescue Stripe::CardError => e
      raise e.message
    end
  end
end
