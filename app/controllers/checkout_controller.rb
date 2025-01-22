class CheckoutController < ApplicationController
  include ProductFinder

  def new
  end

  def create
    result = Orders::CheckoutService.new(@product, params[:stripeToken], current_user.name, current_user.email).process
    handle_response(result)
  end

  private

  def handle_response(result)
    if result[:success]
      redirect_to order_path(result[:order]), notice: result[:message]
    else
      flash[:error] = result[:message]
      render :new
    end
  end
end