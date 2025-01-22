#used in the checkout controller
module ProductFinder
  extend ActiveSupport::Concern

  included do
    before_action :set_product, only: [:new, :create]
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
