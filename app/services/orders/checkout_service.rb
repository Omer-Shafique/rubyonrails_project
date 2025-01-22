#this service is used in the checkout controller
#this service is used in the stripe controller

module Orders
  class CheckoutService
    def initialize(product, stripe_token, user_name, user_email)
      @product = product
      @stripe_token = stripe_token
      @user_name = user_name
      @user_email = user_email
    end

    def process
      charge = process_checkout

      if charge
        Products::InventoryService.update_inventory(@product, -1)
        { success: true, order: Order.create!(product: @product), message: "Payment Successful. Thank you for your purchase!" }
      else
        { success: false, message: "Payment failed. Please try again." }
      end
    rescue Stripe::CardError => e
      { success: false, message: e.message }
    end

    private

    #tbd
    def process_checkout
      image_url = fetch_product_image_url 

      charge = Stripe::Charge.create(
        amount: (@product.price * 100).to_i,
        currency: "usd",
        description: "#{@product.product_title} - #{image_url}",
        source: @stripe_token,
        receipt_email: @user_email,
        metadata: { "Name" => @user_name, "Email" => @user_email, "Product Image" => image_url }
      )

      charge.paid
    end

    def fetch_product_image_url
      @product.images.attached? ? Rails.application.routes.url_helpers.rails_blob_path(@product.images.first, only_path: true) : nil
    end
  end
end
