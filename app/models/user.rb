class User < ApplicationRecord
  has_secure_password

  has_one :oauth_token

  def app_owner?
    discord_user_id == Discord::Api.bot_owner.id
  end

  def owned_guilds
    Discord::Api.user_guilds(access_token).select(&:owner)
  end

  def guild_owner?(guild_id)
    discord_user_id == Discord::Api.get_guild(guild_id).owner_id
  end

  def access_token
    oauth_token.access_token
  end

  def to_token_payload
    {
      sub: self.id,
      name: self.username
    }
  end
end
