class CreateOauthTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :oauth_tokens do |t|
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires

      t.timestamps
    end
  end
end
