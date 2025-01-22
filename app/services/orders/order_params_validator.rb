# used in the stripe payment service which is called in the order controller

module Orders
  class OrderParamsValidator
    def self.validate(order_params)
      missing_params = []

      [:name, :email, :address, :phone].each do |param|
        missing_params << param unless order_params[param].present?
      end

      raise "Missing required parameters: #{missing_params.join(', ')}" unless missing_params.empty?
    end
  end
end
