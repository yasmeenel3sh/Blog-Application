class Api::V1::CommentsController < ApplicationController
  before_action :set_comment, only: [ :update, :destroy ]
  before_action :check_owner, only: [ :update, :destroy ]


  def create
    comment = @current_user.comments.build(comment_params)
    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :post_id)
  end

  def set_comment
    @comment = Comment.find(params[:id])
    unless @comment
        render json: { error: "Comment not found" }, status: :not_found
    end
  end

  def check_owner
    render json: { error: "Unauthorized" }, status: :forbidden unless @comment.user == @current_user
  end
end
