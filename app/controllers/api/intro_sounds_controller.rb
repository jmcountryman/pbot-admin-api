module Api
  class IntroSoundsController < ApplicationController
    before_action :authenticate_user
    before_action :set_sound, only: [:update, :destroy]

    def index
      sounds = []

      # Only fetch sounds for guilds the user and bot are both in
      user_guild_ids = Discord::Api.user_guilds(current_user.access_token).map { |g| g['id'] }
      bot_guild_ids = Discord::Api.bot_guilds.map{ |g| g['id'] }
      guild_ids = user_guild_ids & bot_guild_ids

      sounds = guild_ids.map do |guild_id|
        guild = Discord::Api.get_guild(guild_id)
        {
          guild_id: guild_id,
          guild_name: guild['name'],
          guild_icon: guild['icon'],
          sounds: Pbot::IntroSound.for_guild(guild_id)
        }
      end

      render json: sounds
    end

    # TODO: cancancan
    def create
      guild_id, user_id, file = create_params

      new_record = Pbot::IntroSound.build(
        guild_id: guild_id,
        target_user: user_id,
        file: file,
        created_by: current_user.id
      )

      render json: new_record
    end

    def update
      @sound.update(update_params)

      render json: @sound
    end

    def destroy
      @sound.destroy
    end

    private
    
    def create_params
      params.require([:guild, :user, :file])
    end

    def update_params
      params.permit(:enabled)
    end

    def set_sound
      @sound = Pbot::IntroSound.find(params[:id])

      render nothing: true, status: :not_found unless @sound
    end
  end
end
