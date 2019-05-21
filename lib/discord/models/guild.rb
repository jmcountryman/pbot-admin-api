require 'hash_wrapper'

module Discord
  module Models
    class Guild < HashWrapper
      def icon(size = nil)
        icon_hash = @wrapped_hash['icon']
        return nil unless icon_hash

        icon_path = Discord::Api::GUILD_ICON_PATH % {guild_id: self.id, icon_hash: icon_hash}
        size_query = {size: size}.to_query if size

        return "#{URI.join(Discord::Api::DISCORD_CDN_URL, icon_path)}?#{size_query}"
      end
    end
  end
end
