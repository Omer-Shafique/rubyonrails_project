# its function reduce product quantity is called in the stripe charge service

module ProductStripe
  extend ActiveSupport::Concern

  included do
    def create_or_update_stripe_product
      Stripe.api_key = Rails.configuration.stripe[:secret_key]

      if stripe_price_id.blank? || stripe_product_id.blank?
        stripe_product = Stripe::Product.create(
          name: product_title,
          description: product_description
        )
        stripe_price = Stripe::Price.create(
          unit_amount: (price * 100).to_i,
          currency: "usd",
          product: stripe_product.id
        )
        update(
          stripe_product_id: stripe_product.id,
          stripe_price_id: stripe_price.id,
          stripe_inventory_quantity: stock_quantity
        )
      else
        Stripe::Product.update(
          stripe_product_id,
          name: product_title,
          description: product_description,
          metadata: { stock_quantity: stock_quantity }
        )
      end
    end

    def reduce_stripe_quantity(quantity_to_reduce = 1)
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
      return false unless stripe_product_id.present?
    
      begin
        # Retrieve the Stripe product and price
        stripe_product = Stripe::Product.retrieve(stripe_product_id)
        stripe_price = Stripe::Price.list(product: stripe_product_id).data.first.unit_amount / 100.0
    
        # Validate price consistency
        if stripe_price != price
          Rails.logger.error "Price mismatch for product #{stripe_product_id}. Stripe price: #{stripe_price}, Local price: #{price}"
          return false
        end
    
        # Validate stock availability
        current_stock = stripe_product.metadata['stock_quantity'].to_i
        if current_stock < quantity_to_reduce
          Rails.logger.error "Insufficient stock on Stripe for product #{stripe_product_id}. Current stock: #{current_stock}, Required: #{quantity_to_reduce}"
          return false
        end
    
        # Update stock on Stripe
        new_stock = current_stock - quantity_to_reduce
        Stripe::Product.update(stripe_product_id, metadata: { stock_quantity: new_stock })
    
        # Update stock locally
        self.stock_quantity -= quantity_to_reduce
        save!
    
        true
      rescue Stripe::InvalidRequestError => e
        Rails.logger.error "Stripe error for product #{stripe_product_id}: #{e.message}"
        false
      rescue StandardError => e
        Rails.logger.error "Unexpected error while reducing stock for product #{stripe_product_id}: #{e.message}"
        false
      end
    end
    
    
  end
end
