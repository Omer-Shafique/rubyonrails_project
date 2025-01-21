class Admin::OrdersController < ApplicationController
  before_action :set_order, only: [:fulfill, :out_for_delivery, :delivered]

  def fulfill
    @order = Order.find(params[:id])
    if @order.update(status: 'Fulfilled')
      respond_to do |format|
        format.js 
      end
    else
      flash[:error] = "Unable to update order status."
      redirect_to admin_dashboard_path
    end
  end

  def out_for_delivery
    @order = Order.find(params[:id])
    if @order.update(status: 'Out for Delivery')
      respond_to do |format|
        format.js
      end
    else
      flash[:error] = "Unable to update order status."
      redirect_to admin_dashboard_path
    end
  end
  
  def delivered
    @order = Order.find(params[:id])
    if @order.update(status: 'Delivered')
      respond_to do |format|
        format.js
      end
    else
      flash[:error] = "Unable to update order status."
      redirect_to admin_dashboard_path
    end
  end
  
  private

  def set_order
    @order = Order.find_by(id: params[:id])
  end
end
