class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy checkout]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @products = Product.all
    @product_service = Products::ProductService.new(nil, params.merge(current_user: current_user))
  end

  def new
    @product = current_user.products.build
  end
  
  def show
    @products = Product.where(user: current_user)
    @review = @product.reviews.first #tbd
  end

  #tbd
  def search
    @products = Products::ProductService.new(nil, params).search_products
    respond_to do |format|
      format.js  
      format.html
    end
  end

  def create
    @product = current_user.products.build(product_params)
    product_service = Products::ProductService.new(@product, params)
  
    if product_service.create_product
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new
    end
  end

  def edit; end

  def update
    product_service = Products::ProductService.new(@product, params)

    if product_service.update_product(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    product_service = Products::ProductService.new(@product)

    result = product_service.archive_and_destroy_product

    if result[:success]
      flash[:success] = result[:success]
    else
      flash[:alert] = result[:alert]
    end

    redirect_to products_path
  end


  def checkout
    @product = Product.find(params[:id])
    @product_service = Products::ProductService.new(@product, params.merge(current_user: current_user))
    begin
      charge = @product_service.create_stripe_charge
      if @product_service.handle_successful_payment(charge)
        @order = @product_service.create_order
        if @order.save
          redirect_to order_path(@order)
        else
          flash[:error] = "Failed to create the order."
          render 'orders/checkout'
        end
      else
        flash[:error] = "Transaction Failed - Stripe product unavailable or price mismatch."
        render 'orders/checkout'
      end
    rescue => e
      logger.error "An error occurred: #{e.message}"
      logger.error e.backtrace.join("\n") 
      render 'orders/checkout'
    end
    
  end
  
  
  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:product_title, :product_description, :product_sku, :stock_quantity_string, :user_id, :price, :stripe_price_id, images: [])
  end

  
  def correct_user
    @product = Product.find(params[:id])
    redirect_to root_url, notice: "Not authorized" unless @product.user == current_user
  end
end
