class UpdateUserColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :access_token
    remove_column :users, :refresh_token
    remove_column :users, :email
    rename_column :users, :name, :username
  end
end
