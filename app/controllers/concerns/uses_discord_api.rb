module UsesDiscordApi
  extend ActiveSupport::Concern

  def discord_api
    Discord::DiscordApi
  end
end
