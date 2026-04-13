class AdminController < ApplicationController
  include HtmlFilterHelper
  include SmileyHelper

  before_action :require_admin, only: [:edit, :update, :destroy]

  def login
  end

  def authenticate
    if params[:password] == ENV["GRIXNIX_ADMIN_PASSWORD"]
      session[:admin] = true
      redirect_to root_path, notice: "Logged in as admin."
    else
      flash.now[:alert] = "Invalid password."
      render :login, status: :unprocessable_entity
    end
  end

  def logout
    session.delete(:admin)
    redirect_to root_path, notice: "Logged out."
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    attrs = post_params
    attrs[:subject] = sanitize_subject(attrs[:subject])
    attrs[:body] = sanitize_body(attrs[:body])

    if @post.update(attrs)
      redirect_to thread_path(@post.thread_id), notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    thread = @post.discussion_thread
    @post.destroy

    if thread.posts.empty?
      thread.destroy
      redirect_to root_path, notice: "Post and empty thread deleted."
    else
      redirect_to thread_path(thread), notice: "Post deleted."
    end
  end

  private

  def require_admin
    unless session[:admin]
      redirect_to admin_login_path, alert: "Please log in as admin."
    end
  end

  def post_params
    params.require(:post).permit(:username, :subject, :body)
  end
end
