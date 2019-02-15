module Discord
  class Api
    include HTTParty

    DISCORD_CDN_URL = 'https://cdn.discordapp.com/'

    GUILD_ICON_PATH = 'icons/%{guild_id}/%{icon_hash}.png'
    USER_AVATAR_PATH = 'avatars/%{user_id}/%{avatar_hash}.png'

    base_uri 'https://discordapp.com/api'

    # User token endpoints
    def self.auth(code, redirect_uri)
      self.post('/oauth2/token', body: auth_data(code, redirect_uri))
    end

    def self.current_user(user_token)
      self.get('/users/@me', headers: {Authorization: "Bearer #{user_token}"})
    end

    def self.user_guilds(user_token)
      self.get('/users/@me/guilds', headers: {Authorization: "Bearer #{user_token}"})
    end

    # Bot token endpoints
    def self.bot_user
      self.get('/users/@me', headers: bot_header)
    end

    def self.bot_guilds
      self.get('/users/@me/guilds', headers: bot_header)
    end

    def self.get_user(user_id)
      self.get("/users/#{user_id}", headers: bot_header)
    end

    def self.get_guild(guild_id)
      cache_key = "guild/#{guild_id}"

      Rails.cache.fetch(cache_key) do
        self.get("/guilds/#{guild_id}", headers: bot_header).to_hash
      end
    end

    def self.guild_name(guild_id)
      self.get_guild(guild_id)['name']
    end

    def self.guild_icon(guild_id, size=nil)
      guild = self.get_guild(guild_id)
      icon_hash = guild['icon']

      return nil unless icon_hash

      icon_path = GUILD_ICON_PATH % {guild_id: guild_id, icon_hash: icon_hash}
      size_query = {size: size}.to_query if size

      return "#{URI.join(DISCORD_CDN_URL, icon_path)}?#{size_query}"
    end
    
    private
    
    def self.auth_data(code, redirect_uri)
      {
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirect_uri,
        scope: 'identify guilds',
        client_id: client_id,
        client_secret: client_secret
      }
    end

    def self.client_id
      Rails.application.credentials[Rails.env.to_sym][:discord_client_id]
    end

    def self.client_secret
      Rails.application.credentials[Rails.env.to_sym][:discord_client_secret]
    end

    def self.client_token
      Rails.application.credentials[Rails.env.to_sym][:discord_client_token]
    end

    def self.bot_header
      {Authorization: "Bot #{client_token}"}
    end
  end
end
