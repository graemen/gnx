class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.integer :thread_id
      t.integer :original_timestamp
      t.string :username
      t.string :subject
      t.text :body
      t.string :ip_address

      t.timestamps
    end
    add_index :posts, :thread_id
  end
end
