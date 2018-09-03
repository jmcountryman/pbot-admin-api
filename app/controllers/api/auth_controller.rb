module Api
  class AuthController < ApplicationController
    def post
      return render plain: 'Auth code missing', status: :bad_request unless params[:code]

      auth_response = Discord::DiscordApi.auth(params[:code])

      return head :not_authorized if auth_response.code == 401

      expires = DateTime.now + auth_response['expires_in'].seconds

      user_response = Discord::DiscordApi.discord_user(auth_response['access_token'])

      return head :not_authorized if response.code == 401

      user = User.find_or_create_by!(discord_user_id: user_response['id']) do |user|
        # knock requires users to have passwords, even though we're using OAuth
        user.password = SecureRandom.hex(16)
      end

      token_attributes = {
        access_token: auth_response['access_token'],
        refresh_token: auth_response['refresh_token'],
        expires: expires
      }

      if user.oauth_token.nil?
        user.oauth_token = OauthToken.create(token_attributes)
      else
        user.oauth_token.update(token_attributes)
      end

      head :ok
    end
  end
end
