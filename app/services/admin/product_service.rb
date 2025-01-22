# used in the product controller in the admin namespace

module Admin
  class ProductService
    def initialize(params)
      @params = params
      @product = Product.new(@params)
    end

    def create_product
      if @product.save
        true
      else
        false
      end
    end

    def update_product(product)
      if product.update(@params)
        true
      else
        false
      end
    end
  end
end