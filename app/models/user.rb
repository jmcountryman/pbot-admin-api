class User < ApplicationRecord
  has_secure_password

  has_one :oauth_token

  def self.from_token_payload(payload)
    payload['sub']
  end
end
