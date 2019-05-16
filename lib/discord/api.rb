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

      # Get the user profile using their token
      def user_info_from_token(user_token)
        self.get('/users/@me', headers: {Authorization: "Bearer #{user_token}"})
      end

      # This takes the user_token instead of a user ID because the bot can't see users' guilds
      def user_guilds(user_token)
        cached "users/#{user_from_token(user_token).id}/guilds" do
          JSON.parse self.get('/users/@me/guilds', headers: {Authorization: "Bearer #{user_token}"}).body
        end
      end

      # Bot token endpoints
      def bot_user
        cached 'users/bot' do
          self.get('/users/@me', headers: bot_header).to_h
        end
      end

      def bot_guilds
        cached 'users/bot/guilds' do
          JSON.parse self.get('/users/@me/guilds', headers: bot_header).body
        end
      end

      def get_user(user_id)
        cached "users/#{user_id}" do
          user = self.get("/users/#{user_id}", headers: bot_header).to_h
          user['avatar'] = avatar_for_user(user)

          user
        end
      end

      def get_guild(guild_id)
        cached "guild/#{guild_id}" do
          guild = self.get("/guilds/#{guild_id}", headers: bot_header).to_h
          guild['icon'] = icon_for_guild(guild)

          guild
        end
      end
      
      private

      def cached(key, &block)
        Rails.cache.fetch(key, expires_in: CACHE_LIFETIME) do
          Rails.logger.info "Cache miss for '#{key}'"
          
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

      # Get the user record from the database based on their stored access token
      def user_from_token(user_token)
        User.joins(:oauth_token).where(oauth_tokens: {access_token: user_token}).first
      end

      def avatar_for_user(user, size=nil)
        avatar_hash = user['avatar']
        return nil unless avatar_hash

        avatar_path = USER_AVATAR_PATH % {user_id: user['id'], avatar_hash: avatar_hash}
        size_query = {size: size}.to_query if size

        return "#{URI.join(DISCORD_CDN_URL, avatar_path)}?#{size_query}"
      end

      def icon_for_guild(guild, size=nil)
        icon_hash = guild['icon']
        return nil unless icon_hash

        icon_path = GUILD_ICON_PATH % {guild_id: guild['id'], icon_hash: icon_hash}
        size_query = {size: size}.to_query if size

        return "#{URI.join(DISCORD_CDN_URL, icon_path)}?#{size_query}"
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
