class Admin::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @products = Product.all
  end

  def new
    @product = Product.new
  end

  def create
    product_service = Admin::ProductService.new(product_params)
    if product_service.create_product
      redirect_to admin_products_path, notice: 'Product created successfully.'
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    product_service = Admin::ProductService.new(product_params)
    if product_service.update_product(@product)
      redirect_to admin_products_path, notice: 'Product updated successfully.'
    else
      render :edit
    end
  end

  
  def destroy #tbd
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_products_path, notice: 'Product deleted successfully.'
  end

  private

  def product_params
    params.require(:product).permit(
      :product_title,
      :product_description,
      :product_sku,
      :stock_quantity_string,
      :user_id,
      :price,
      :stripe_price_id,
      images: []
    )
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end
