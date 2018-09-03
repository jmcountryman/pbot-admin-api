class AddDiscordUserIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :discord_user_id, :string
  end
end
