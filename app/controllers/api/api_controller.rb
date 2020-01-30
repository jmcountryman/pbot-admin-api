module Api
  class ApiController < ApplicationController
    include Pundit

    before_action :authenticate_user, except: :root

    rescue_from Discord::Errors::DiscordApiError, with: :handle_discord_error

    def root
      head :ok
    end

    def handle_discord_error(ex)
      render json: {
        error: ex
      }, status: :internal_server_error
    end
  end
end
