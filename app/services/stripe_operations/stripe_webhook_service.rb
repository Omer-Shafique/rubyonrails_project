#this service is used in the stripe controller

module StripeOperations
  class StripeWebhookService
    def initialize(payload, sig_header, endpoint_secret)
      @payload = payload
      @sig_header = sig_header
      @endpoint_secret = endpoint_secret
    end

    def process_webhook
      event = construct_event
      return false unless event

      handle_event(event)
      true
    rescue StandardError => e
      Rails.logger.error("Stripe webhook error: #{e.message}")
      false
    end

    private

    def construct_event
      Stripe::Webhook.construct_event(@payload, @sig_header, @endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      nil
    end

    def handle_event(event)
      case event["type"]
      when "charge.succeeded"
        charge = event["data"]["object"]
        product = Product.find_by(title: charge["description"])
        product.update!(stock_quantity_string: product.stock_quantity_string.to_i - 1) if product
      end
    end
  end
end
