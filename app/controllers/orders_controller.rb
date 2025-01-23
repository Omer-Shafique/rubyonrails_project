class OrdersController < ApplicationController
  include OrderFinder
  before_action :authenticate_user!

  def index
    @orders = current_user.orders 
  end

  def show
    @orders = current_user.orders.paginate(page: params[:page], per_page: 1)
  end
  
end