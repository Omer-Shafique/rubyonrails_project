module Reviews
  class ReviewService
    def initialize(product, user, review_params, rating)
      @product = product
      @user = user
      @review_params = review_params
      @rating = rating
    end

    def create_or_update_review
      existing_review = @product.reviews.find_by(user: @user)

      if existing_review
        update_review(existing_review)
      else
        create_review
      end
    end

    def destroy_review(review)
      review.destroy
    end

    def toggle_like(review)
      if review.likes.exists?(user: @user)
        review.likes.find_by(user: @user).destroy
      else
        review.likes.create(user: @user)
      end
    end

    private

    def create_review
      review = @product.reviews.build(@review_params)
      review.user = @user
      review.rating = 6 - @rating.to_i
      review.save
    end

    def update_review(existing_review)
      existing_review.update(@review_params)
      existing_review.rating = 6 - @rating.to_i
      existing_review.save
    end
  end
end
