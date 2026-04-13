class ThreadsController < ApplicationController
  include HtmlFilterHelper
  include SmileyHelper

  def index
    @threads = DiscussionThread.order(last_post_at: :desc).page(params[:page]).per(10)
    # Preload first posts for display
    thread_ids = @threads.map(&:id)
    @first_posts = Post.where(thread_id: thread_ids)
                       .group_by(&:thread_id)
                       .transform_values { |posts| posts.min_by(&:created_at) }
    @reply_counts = Post.where(thread_id: thread_ids)
                        .group(:thread_id)
                        .count
  end

  def show
    @thread = DiscussionThread.find(params[:id])
    @posts = @thread.posts.order(:created_at).page(params[:page]).per(9)
    @post = Post.new
  end

  def new
    @post = Post.new
  end

  def create
    if params[:preview]
      @post = Post.new(post_params)
      @preview_subject = sanitize_subject(@post.subject)
      @preview_body = smilize(sanitize_body(@post.body))
      render :new
      return
    end

    ActiveRecord::Base.transaction do
      @thread = DiscussionThread.create!(last_post_at: Time.current)
      @post = @thread.posts.build(post_params)
      @post.ip_address = request.remote_ip
      @post.subject = sanitize_subject(@post.subject)
      @post.body = sanitize_body(@post.body)
      @post.save!
    end
    redirect_to thread_path(@thread), notice: "Thread created."
  rescue ActiveRecord::RecordInvalid
    @thread&.destroy if @thread&.persisted?
    @post ||= Post.new(post_params)
    render :new, status: :unprocessable_entity
  end

  private

  def post_params
    params.require(:post).permit(:username, :subject, :body)
  end
end
