class RemoveTagsFromPosts < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :tags, :string
  end
end
