module Pbot
  class IntroSound
    include Mongoid::Document
    include Mongoid::Timestamps

    field :guild_id, type: String
    field :target_user, type: String
    field :file_id, type: BSON::ObjectId
    field :enabled, type: Boolean, default: true
    field :created_by, type: String

    def self.build(guild_id:, target_user:, file:, created_by:)
      file_id = MongoFs.fs.upload_from_stream(file.original_filename, file)

      self.create!(
        target_user: target_user,
        guild_id: guild_id,
        file_id: file_id,
        created_by: created_by
      )
    end

    def self.for_guild(guild_id)
      where(guild_id: guild_id)
    end

    def self.for_user(guild_id, user_id)
      where(guild_id: guild_id, target_user: user_id)
    end

    def sound_file
      MongoFs.fs.find({_id: BSON::ObjectId(file_id)}, limit: -1).first
    end

    def as_json(options = {})
      {
        id: id.to_s,
        # TODO: target_user: 
        enabled: enabled,
        file: {
          id: sound_file['_id'].to_s,
          filename: sound_file['filename']
        }
      }
    end
  end
end