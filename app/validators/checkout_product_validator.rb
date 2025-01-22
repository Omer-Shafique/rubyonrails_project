#this service is used in the stripe controller

class CheckoutProductValidator
  attr_reader :errors, :user_name, :user_email

  def initialize(params)
    @params = params
    @errors = []
    @user_name = params[:name]
    @user_email = params[:email]
  end

  def valid?
    validate_name
    validate_email
    errors.empty?
  end

  private

  def validate_name
    errors << "Name is required" if @user_name.blank?
  end

  def validate_email
    errors << "Email is required" if @user_email.blank?
  end
end
