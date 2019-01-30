class MongoFs
  def self.fs
    @mongo_fs ||= Mongo::Grid::FSBucket.new(database)
  end

  private

  def self.database
    # from mongoid.yml
    @mongo_files_db ||= Mongoid.default_client.database
  end
end
