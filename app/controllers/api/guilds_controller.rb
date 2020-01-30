module Api
  class GuildsController < ApiController
    def index
      guilds = policy_scope(:guild) do |guild_id|
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
