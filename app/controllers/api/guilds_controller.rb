module Api
  class GuildsController < ApiController
    include UsesGuilds

    def index
      guilds = allowed_guild_ids.map do |guild_id|
        guild = Discord::Api.get_guild(guild_id)
        {
          id: guild_id,
          name: guild.name,
          icon: guild.icon,
        }
      end

      render json: guilds
    end
  end
end
