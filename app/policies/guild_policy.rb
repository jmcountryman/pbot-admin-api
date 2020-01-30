class GuildPolicy < Struct.new(:user, :guild)
  class Scope < ApplicationPolicy::Scope
    def initialize(user, scope)
      @user = user
    end

    def resolve
      puts "Guild scope for user #{user}"
      bot_guild_ids = Discord::Api.bot_guilds.map(&:id)
      # return bot_guild_ids if user.app_owner?

      user_guild_ids = Discord::Api.user_guilds(user.access_token).map(&:id)
      user_guild_ids & bot_guild_ids
    end
  end
end
