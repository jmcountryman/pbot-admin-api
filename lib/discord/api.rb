module Discord
  class Api
    include HTTParty

    DISCORD_CDN_URL = 'https://cdn.discordapp.com/'

    GUILD_ICON_PATH = 'icons/%{guild_id}/%{icon_hash}.png'
    USER_AVATAR_PATH = 'avatars/%{user_id}/%{avatar_hash}.png'

    CACHE_LIFETIME = 24.hours

    base_uri 'https://discordapp.com/api'

    class << self
      # User token endpoints
      def auth(code, redirect_uri)
        self.post('/oauth2/token', body: auth_data(code, redirect_uri))
      end

      def current_user(user_token)
        cached "users/#{current_user.discord_user_id}" do
          self.get('/users/@me', headers: {Authorization: "Bearer #{user_token}"}).to_h
        end
      end

      def user_guilds(user_token)
        cached "users/#{current_user.discord_user_id}/guilds" do
          self.get('/users/@me/guilds', headers: {Authorization: "Bearer #{user_token}"}).to_h
        end
      end

      # Bot token endpoints
      def bot_user
        cached 'users/bot' do
          self.get('/users/@me', headers: bot_header).to_h
        end
      end

      def bot_guilds
        cached 'users/bot/guild' do
          self.get('/users/@me/guilds', headers: bot_header).to_h
        end
      end

      def get_user(user_id)
        cached "users/#{user_id}" do
          self.get("/users/#{user_id}", headers: bot_header).to_h
        end
      end

      def get_guild(guild_id)
        cached "guild/#{guild_id}" do
          self.get("/guilds/#{guild_id}", headers: bot_header).to_h
        end
      end

      def guild_name(guild_id)
        self.get_guild(guild_id)['name']
      end

      def guild_icon(guild_id, size=nil)
        guild = self.get_guild(guild_id)
        icon_hash = guild['icon']

        return nil unless icon_hash

        icon_path = GUILD_ICON_PATH % {guild_id: guild_id, icon_hash: icon_hash}
        size_query = {size: size}.to_query if size

        return "#{URI.join(DISCORD_CDN_URL, icon_path)}?#{size_query}"
      end
      
      private

      def cached(key, &block)
        Rails.cache.fetch(key, expires_in: CACHE_LIFETIME) do
          block.call
        end
      end
      
      def auth_data(code, redirect_uri)
        {
          grant_type: 'authorization_code',
          code: code,
          redirect_uri: redirect_uri,
          scope: 'identify guilds',
          client_id: client_id,
          client_secret: client_secret
        }
      end

      def client_id
        Rails.application.credentials[Rails.env.to_sym][:discord_client_id]
      end

      def client_secret
        Rails.application.credentials[Rails.env.to_sym][:discord_client_secret]
      end

      def client_token
        Rails.application.credentials[Rails.env.to_sym][:discord_client_token]
      end

      def bot_header
        {Authorization: "Bot #{client_token}"}
      end
    end
  end
end
