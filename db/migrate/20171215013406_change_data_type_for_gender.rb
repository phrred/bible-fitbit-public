class ChangeDataTypeForGender < ActiveRecord::Migration[5.1]
  def change
  	    change_column :users, :gender, 'boolean USING gender::boolean'
  end
end
