module Api
  class IntroSoundsController < ApiController
    include UsesGuilds

    before_action :verify_guild_access, except: :index
    before_action :set_sound, only: [:update, :destroy]

    def index
      return render json: [] unless allowed_guild_ids.include? params[:guild_id]

      render json: Pbot::IntroSound.for_guild(params[:guild_id])
    end

    # TODO: pundit
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

    def verify_guild_access
      head :forbidden unless allowed_guild_ids.include? params[:guild_id]
    end
    
    def create_params
      params.require([:guild_id, :user, :file])
    end

    def update_params
      params.permit(:enabled)
    end

    def set_sound
      @sound = Pbot::IntroSound.where(guild_id: params[:guild_id]).find(params[:id])

      head :not_found unless @sound
    end
  end
end
