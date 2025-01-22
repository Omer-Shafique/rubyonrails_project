#not in use for now!
class WishlistsController < ApplicationController
  before_action :authenticate_user!

  def index
    @wishlisted_products = Wishlists::WishlistService.new(current_user).fetch_wishlist
  end

  def create
    product = Product.find(params[:product_id])
    service = Wishlists::WishlistService.new(current_user)
    if service.add_to_wishlist(product)
      redirect_to product_path(product), notice: "Product added to wishlist"
    else
      redirect_to product_path(product), alert: "Failed to add product to wishlist"
    end
  end

  def destroy
    service = Wishlists::WishlistService.new(current_user)
    if service.remove_from_wishlist(params[:product_id])
      redirect_to product_path(params[:product_id]), notice: "Product removed from wishlist"
    else
      redirect_to product_path(params[:product_id]), alert: "Failed to remove product from wishlist"
    end
  end
end