module Discord
  class DiscordApi
    include HTTParty

    base_uri 'https://discordapp.com/api'

    def self.auth(code)
      self.post('/oauth2/token', body: auth_data(code))
    end

    def self.discord_user(access_code)
      self.get('/users/@me', headers: {Authorization: "Bearer #{access_code}"})
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
  end
end
