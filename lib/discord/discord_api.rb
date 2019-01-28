module Discord
  class DiscordApi
    include HTTParty

    base_uri 'https://discordapp.com/api'

    def self.auth(code)
      self.post('/oauth2/token', body: auth_data(code))
    end

    def self.bot_user
      self.get('/users/@me', headers: {Authorization: "Bot #{client_token}"})
    end

    def self.current_user(user_token)
      self.get('/users/@me', headers: {Authorization: "Bearer #{user_token}"})
    end

    def self.get_user(user_id)
      self.get("/users/#{user_id}", headers: {Authorization: "Bot #{client_token}"})
    end
    
    private
    
    def self.auth_data(code)
      {
        grant_type: 'authorization_code',
        code: code,
        # TODO: update this
        redirect_uri: 'http://localhost:8000/auth/return',
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
