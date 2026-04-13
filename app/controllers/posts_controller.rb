class PostsController < ApplicationController
  include HtmlFilterHelper
  include SmileyHelper

  def create
    @thread = DiscussionThread.find(params[:thread_id])

    if params[:preview]
      @post = Post.new(post_params)
      @preview_subject = sanitize_subject(@post.subject)
      @preview_body = smilize(sanitize_body(@post.body))
      @posts = @thread.posts.order(:created_at).page(params[:page]).per(9)
      render "threads/show"
      return
    end

    @post = @thread.posts.build(post_params)
    @post.ip_address = request.remote_ip
    @post.subject = sanitize_subject(@post.subject)
    @post.body = sanitize_body(@post.body)

    if @post.save
      redirect_to thread_path(@thread, page: @thread.posts.count / 9 + 1), notice: "Reply posted."
    else
      @posts = @thread.posts.order(:created_at).page(params[:page]).per(9)
      render "threads/show", status: :unprocessable_entity
    end
  end

  def preview
    @thread = DiscussionThread.find(params[:thread_id])
    @post = Post.new(post_params)
    @preview_subject = sanitize_subject(@post.subject)
    @preview_body = smilize(sanitize_body(@post.body))
    @posts = @thread.posts.order(:created_at).page(params[:page]).per(9)
    render "threads/show"
  end

  private

  def post_params
    params.require(:post).permit(:username, :subject, :body)
  end
end
