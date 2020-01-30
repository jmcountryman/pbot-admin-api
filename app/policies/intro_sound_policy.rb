class IntroSoundPolicy < ApplicationPolicy
  attr_reader :user, :sound

  def initialize(user, sound)
    @user = user
    @sound = sound
  end

  class Scope < Scope
    def resolve
      return scope.all if user.app_owner?

      scope.where(guild_id: user.owned_guilds.map(&:id)) |
        scope.where(target_user: user.discord_user_id)
    end
  end

  def create?
    allowed?
  end

  def update?
    allowed?
  end

  def destroy?
    allowed?
  end

  private

  def allowed?
    user.app_owner? ||
      user.guild_owner?(sound.guild_id) ||
      sound.target_user == user.discord_user_id
  end
end
