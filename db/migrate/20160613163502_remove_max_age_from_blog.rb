class RemoveMaxAgeFromBlog < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :blogs, :max_age
  end

  def self.down
    add_column :blogs, :max_age, :integer, default: 5
  end
end
