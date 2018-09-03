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
        # TODO: get these from Rails.app.secrets
        client_id: '431216339894534145',
        client_secret: 'LaJLtKLXpxGrP2h8-w2EOJoK27TIhnqh',
      }
    end
  end
end
