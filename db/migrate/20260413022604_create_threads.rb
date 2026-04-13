class CreateThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :threads do |t|
      t.integer :original_timestamp
      t.datetime :last_post_at

      t.timestamps
    end
    add_index :threads, :last_post_at
  end
end
