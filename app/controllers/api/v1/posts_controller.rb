class Api::V1::PostsController < ApplicationController
  before_action :authorize_request
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :check_owner, only: [:update, :destroy]

  def index
    # Eager loading for performance
    posts = Post.includes(:tags, :comments).all
    render json: posts, include: [:tags, :comments]
  end

  def show
    render json: @post, include: [:tags, :comments]
  end

  def create
    post = @current_user.posts.build(post_params)

    if post.save
      PostCleanupJob.set(wait: 24.hours).perform_later(post.id)
      render json: post, include: :tags, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    head :no_content
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, tag_ids: [])
  end

  def set_post
    @post = Post.find(params[:id])
    unless @post
        render json: { error: "Post not found" }, status: :not_found
  end

  def check_owner
    render json: { error: "Unauthorized" }, status: :forbidden unless @post.user == @current_user
  end
end
