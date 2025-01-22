# used in the order controller

module OrderFinder
  extend ActiveSupport::Concern

  included do
    before_action :set_order, only: [:show]
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])
    if @order.nil?
      flash[:error] = "Order not found"
      redirect_to root_path
    end
  end
end
