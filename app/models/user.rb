class User < ApplicationRecord
  has_secure_password

  has_one :oauth_token

  def access_token
    oauth_token.access_token
  end

  def to_token_payload
    {
      sub: self.id,
      name: self.username
    }
  end
end
