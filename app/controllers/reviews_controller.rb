class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review, only: [:destroy, :like]

  def index
    @reviews = Review.all
  end

  def create
    @product = Product.find(params[:product_id])
    review_service = Reviews::ReviewService.new(@product, current_user, review_params, params[:review][:rating])

    if review_service.create_or_update_review
      redirect_to @product, notice: 'Your review has been updated successfully.'
    else
      flash[:alert] = 'Failed to create/update review. Please correct the errors below.'
      redirect_to @product
    end
  end

  def destroy
    review_service = Reviews::ReviewService.new(@review.product, current_user, nil, nil)
    if current_user == @review.user || current_user.admin?
      review_service.destroy_review(@review)
      redirect_to product_path(@review.product), notice: "Review deleted successfully."
    else
      redirect_to product_path(@review.product), alert: "You are not authorized to delete this review."
    end
  end

  def like
    review_service = Reviews::ReviewService.new(@review.product, current_user, nil, nil)
    review_service.toggle_like(@review)

    respond_to do |format|
      format.js
    end
  end

  private

  def set_review
    @review = Review.find_by(id: params[:id])
    redirect_to products_path, alert: "Review not found." unless @review
  end

  def review_params
    params.require(:review).permit(:product_id, :rating, :content)
  end
end
