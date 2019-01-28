module Api
  class IntroSoundsController < ApplicationController
    before_action :authenticate_user

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

    private
    
    def create_params
      params.require([:guild, :user, :file])
    end
  end
end
