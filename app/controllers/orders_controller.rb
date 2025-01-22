# flow is little complex, will work on making the code easy to understand.

class OrdersController < ApplicationController
  include OrderFinder
  before_action :authenticate_user!

  def index
    @orders = current_user.orders 
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
  
  def checkout
    stripe_token = params[:stripeToken]
    order_params = {
      product_id: params[:id],
      name: params[:name],
      email: params[:email],
      address: params[:address],
      phone: params[:phone]
    }

    service = StripeOperations::StripePaymentService.new(order_params, stripe_token)

    begin
      order = service.create_order_and_process_payment
      redirect_to order_path(order), notice: "Order placed successfully!"
    rescue StandardError => e
      redirect_to checkout_product_path(Product.find(params[:id])), alert: "Payment failed: #{e.message}"
    end
  end
end
