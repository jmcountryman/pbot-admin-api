module Discord
  class Api
    include HTTParty

    base_uri 'https://discordapp.com/api'

    def self.auth(code, redirect_uri)
      self.post('/oauth2/token', body: auth_data(code, redirect_uri))
    end

    def self.bot_user
      self.get('/users/@me', headers: {Authorization: "Bot #{client_token}"})
    end

    def self.bot_guilds
      self.get('/users/@me/guilds', headers: {Authorization: "Bot #{client_token}"})
    end

    def self.current_user(user_token)
      self.get('/users/@me', headers: {Authorization: "Bearer #{user_token}"})
    end

    def self.user_guilds(user_token)
      self.get('/users/@me/guilds', headers: {Authorization: "Bearer #{user_token}"})
    end

    def self.get_user(user_id)
      self.get("/users/#{user_id}", headers: {Authorization: "Bot #{client_token}"})
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
  end
end
