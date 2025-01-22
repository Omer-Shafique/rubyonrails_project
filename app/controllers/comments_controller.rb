class CommentsController < ApplicationController
  before_action :find_review
  before_action :set_comment, only: [:destroy]

  def show
    @product = Product.find(params[:id])
    @review = Review.find_by(product_id: @product.id)
    @comment = Comment.new
  end

  def create
    handle_response(comment_creation_service.call)
  end

  def destroy
    handle_response(comment_destruction_service.call)
  end

  private

  def find_review
    @review = Review.find(params[:review_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def comment_creation_service
    @comment_creation_service ||= Comments::CommentCreationService.new(@review, comment_params, current_user)
  end

  def comment_destruction_service
    @comment_destruction_service ||= Comments::CommentDestructionService.new(@review, params[:id])
  end

  def handle_response(success)
    respond_to do |format|
      if success
        format.js
        format.html { redirect_to @review.product}
      else
        format.js { render :error }
        format.html { redirect_to @review.product}
      end
    end
  end
end
