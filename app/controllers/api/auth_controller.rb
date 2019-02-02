module Api
  class AuthController < ApplicationController
    AUTH_REDIRECT = '/auth/return'

    def post
      return render plain: 'Auth code missing', status: :bad_request unless params[:code]

      # Get Discord OAuth token
      auth_response = Discord::Api.auth(params[:code], redirect_uri)
      return render plain: auth_response.body, status: :not_authorized if auth_response.code == 401

      # Get user info
      expiry = DateTime.now + auth_response['expires_in'].seconds
      user_response = Discord::Api.current_user(auth_response['access_token'])
      return render plain: user_response.body, status: :not_authorized if user_response.code == 401

      # Store tokens
      user = find_user(user_response['id'])
      update_tokens(
        user,
        auth_response['access_token'],
        auth_response['refresh_token'],
        expiry
      )

      # Return JWT
      token = Knock::AuthToken.new(payload: user.to_token_payload).token
      render json: token
    end

    private

    def redirect_uri
      [request.protocol, request.host_with_port, AUTH_REDIRECT].join
    end

    def find_user(discord_user_id)
      User.find_or_create_by!(discord_user_id: discord_user_id) do |user|
        # knock requires users to have passwords. since we're using OAuth, this can be whatever
        user.password = SecureRandom.hex(16)
      end
    end

    def update_tokens(user, access_token, refresh_token, expiry)
      token_attributes = {
        access_token: access_token,
        refresh_token: refresh_token,
        expires: expiry
      }

      if user.oauth_token.nil?
        user.oauth_token = OauthToken.create(token_attributes)
      else
        user.oauth_token.update(token_attributes)
      end
    end
  end
end
