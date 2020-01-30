require 'discord/models/guild'
require 'discord/models/user'
require 'discord/errors'

module Discord
  class Api
    include HTTParty

    DISCORD_CDN_URL = 'https://cdn.discordapp.com/'

    GUILD_ICON_PATH = 'icons/%{guild_id}/%{icon_hash}.png'
    USER_AVATAR_PATH = 'avatars/%{user_id}/%{avatar_hash}.png'

    CACHE_LIFETIME = 24.hours

    base_uri 'https://discordapp.com/api'

    class << self
      def get(*args)
        response = super

        return response.parsed_response if response.ok?

        raise Errors.class_for_code(response.code).new(response.body)
      end

      # User token endpoints
      def auth(code, redirect_uri)
        self.post('/oauth2/token', body: auth_data(code, redirect_uri))
      end

      # Get the user profile using their token
      def user_info_from_token(user_token)
        Discord::Models::User.new(
          self.get('/users/@me', headers: {Authorization: "Bearer #{user_token}"})
        )
      end

      # This takes the user_token instead of a user ID because the bot can't see users' guilds
      def user_guilds(user_token)
        cached "users/#{user_from_token(user_token).id}/guilds" do
          self.get(
            '/users/@me/guilds',
            headers: {Authorization: "Bearer #{user_token}"}
          ).map do |guild|
            Discord::Models::Guild.new(guild)
          end
        end
      end

      # Bot token endpoints
      def bot_user
        cached 'users/bot' do
          Discord::Models::User.new(self.get('/users/@me', headers: bot_header))
        end
      end

      def bot_info
        cached 'applications/bot' do
          self.get('/oauth2/applications/@me', headers: bot_header)
        end
      end

      def bot_owner
        cached 'applications/bot/owner' do
          Discord::Models::User.new(self.bot_info['owner'])
        end
      end

      def bot_guilds
        cached 'users/bot/guilds' do
          self.get('/users/@me/guilds', headers: bot_header).map do |guild|
            Discord::Models::Guild.new(guild)
          end
        end
      end

      def get_user(user_id)
        cached "users/#{user_id}" do
          Discord::Models::User.new(self.get("/users/#{user_id}", headers: bot_header))
        end
      end

      def get_guild(guild_id)
        cached "guild/#{guild_id}" do
          Discord::Models::Guild.new(self.get("/guilds/#{guild_id}", headers: bot_header))
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
