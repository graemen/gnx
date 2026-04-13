class Post < ApplicationRecord
  belongs_to :discussion_thread, foreign_key: "thread_id"

  validate :body_or_subject_present

  def body_or_subject_present
    if body.blank? && subject.blank?
      errors.add(:body, "or subject must be present")
    end
  end

  after_create :update_thread_last_post_at

  private

  def update_thread_last_post_at
    discussion_thread.update_column(:last_post_at, created_at)
  end
end
