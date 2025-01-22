class WishlistService
  def initialize(user)
    @user = user
  end

  def fetch_wishlist
    @user.wishlist_products.includes(:product).map(&:product)
  end

  def add_to_wishlist(product)
    return false if product.nil?

    @user.wishlists.find_or_create_by(product: product)
    true
  rescue StandardError
    false
  end

  def remove_from_wishlist(product_id)
    wishlist = @user.wishlists.find_by(product_id: product_id)
    wishlist&.destroy
    wishlist.present?
  rescue StandardError
    false
  end
end
