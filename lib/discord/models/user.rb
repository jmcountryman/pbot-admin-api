require 'hash_wrapper'

module Discord
  module Models
    class User < HashWrapper
      def avatar_url(size = nil)
        avatar_hash = self.avatar
        return nil unless avatar_hash

        avatar_path = Discord::Api::USER_AVATAR_PATH % {user_id: self.id, avatar_hash: avatar_hash}
        size_query = {size: size}.to_query if size

        "#{URI.join(Discord::Api::DISCORD_CDN_URL, avatar_path)}?#{size_query}"
      end

      def as_json
        {
          id: self.id,
          username: self.username,
          discriminator: self.discriminator,
          avatar: self.avatar_url
        }
      end
    end
  end
end
