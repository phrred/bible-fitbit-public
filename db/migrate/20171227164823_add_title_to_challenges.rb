class AddTitleToChallenges < ActiveRecord::Migration[5.1]
  def change
    add_column :challenges, :title, :string
  end
end
