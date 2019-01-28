class MongoFs
  DATABASE_NAME = ENV['PBOT_FILE_STORE_DB'] || 'pbot_files'

  def self.fs
    @mongo_fs ||= Mongo::Grid::FSBucket.new(database)
  end

  private

  def self.database
    @mongo_files_db ||= Mongo::Database.new(client, DATABASE_NAME)
  end

  def self.client
    @mongo_client ||= Mongoid.default_client
  end
end
