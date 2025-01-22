#used in the comment controller

module Comments
  class CommentCreationService
    def initialize(review, comment_params, user)
      @review = review
      @comment_params = comment_params
      @user = user
    end

    def call
      comment = @review.comments.build(@comment_params)
      comment.user = @user
      comment.save
    end
  end
end