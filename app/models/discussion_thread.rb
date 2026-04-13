class DiscussionThread < ApplicationRecord
  self.table_name = "threads"

  has_many :posts, foreign_key: "thread_id", dependent: :destroy

  def first_post
    posts.order(:created_at).first
  end

  def subject
    first_post&.subject || "(no subject)"
  end

  def author
    first_post&.username.presence || "Anonymous"
  end

  def reply_count
    [posts.count - 1, 0].max
  end
end
