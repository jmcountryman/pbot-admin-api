module Api
  class IntroSoundsController < ApplicationController
    before_action :authenticate_user
    before_action :set_sound, only: [:update, :destroy]

    def index
      sounds = []

      # TODO: only user guilds (or all guilds for app owner)
      sounds = Pbot::IntroSound.distinct(:guild_id).map do |guild|
        # TODO: include guild info (name, icon?)
        {guild_id: guild, sounds: Pbot::IntroSound.for_guild(guild)}
      end

      render json: sounds
    end

    def create
      guild_id, user_id, file = create_params

      new_record = Pbot::IntroSound.build(
        guild_id: guild_id,
        target_user: user_id,
        file: file,
        created_by: current_user
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
      params.permit(:sound_id, :enabled)
    end

    def set_sound
      @sound = Pbot::IntroSound.find(params.require[:sound_id])

      render nothing: true, status: :not_found unless @sound
    end
  end
end
