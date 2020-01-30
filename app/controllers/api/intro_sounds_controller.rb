module Api
  class IntroSoundsController < ApiController
    before_action :verify_guild_access
    before_action :set_sound, only: [:update, :destroy]

    # TODO: rescue_from Pundit authz error

    # TODO: query params
    def index
      render json: policy_scope(IntroSound.where(guild_id: params[:guild_id]))
    end

    def create
      guild_id, user_id, file = create_params

      new_record = IntroSound.build(
        guild_id: guild_id,
        target_user: user_id,
        file: file,
        created_by: current_user.id
      )

      # TODO: defer Mongo upload (override #save?) or tear down new_record if not authorized
      authorize new_record
      new_record.save!

      render json: new_record
    end

    def update
      authorize @sound
      @sound.update(update_params)

      render json: @sound
    end

    def destroy
      authorize @sound
      @sound.destroy
    end

    private

    def verify_guild_access
      head :not_found unless policy_scope(:guild).include? params[:guild_id]
    end

    def create_params
      params.require([:guild_id, :user, :file])
    end

    def update_params
      params.permit(:enabled)
    end

    def set_sound
      @sound = IntroSound.where(guild_id: params[:guild_id]).find(params[:id])

      head :not_found unless @sound
    end
  end
end
