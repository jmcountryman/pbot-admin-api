module Discord
  module Errors
    class DiscordApiError < StandardError; end

    # 400
    class BadRequestError < DiscordApiError; end

    # 401
    class UnauthorizedError < DiscordApiError; end

    # 403
    class ForbiddenError < DiscordApiError; end

    # 404
    class NotFoundError < DiscordApiError; end

    # 5xx
    class ServerError < DiscordApiError; end

    class UnknownError < DiscordApiError; end

    def self.class_for_code(code)
      return ServerError if code / 100 == 5

      case code
      when 400
        BadRequestError
      when 401
        UnauthorizedError
      when 403
        ForbiddenError
      when 404
        NotFoundError
      else
        UnknownError
      end
    end
  end
end
