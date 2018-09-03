class AddUserReferenceToOauthToken < ActiveRecord::Migration[5.2]
  def change
    add_reference :oauth_tokens, :user, foreign_key: true
  end
end
