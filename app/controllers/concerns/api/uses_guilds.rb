module Api
  module UsesGuilds
    extend ActiveSupport::Concern

    def allowed_guild_ids
      user_guild_ids = Discord::Api.user_guilds(current_user.access_token).map(&:id)
      bot_guild_ids = Discord::Api.bot_guilds.map(&:id)
      user_guild_ids & bot_guild_ids
    end
  end
end
