class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    service = StripeOperations::StripeWebhookService.new(payload, sig_header, endpoint_secret)
    if service.process_webhook
      head :ok
    else
      head :bad_request
    end
  end

  def checkout_product
    @product = Product.find(params[:id])
    stripe_token = params[:stripeToken]

    validator = CheckoutProductValidator.new(params)
    if validator.valid?
      service = Orders::CheckoutService.new(@product, validator.user_name, validator.user_email, stripe_token)
      if service.process_checkout
        flash[:success] = "Payment successful! Thank you, #{validator.user_name}."
        redirect_to success_path
      else
        flash[:error] = "Payment failed. Please try again."
        redirect_to checkout_product_path(@product)
      end
    else
      flash[:error] = "Invalid parameters: #{validator.errors.join(', ')}"
      redirect_to checkout_product_path(@product)
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to checkout_product_path(@product)
  end
end
