class VolumeAdjustmentJob < ApplicationJob
  TARGET_VOLUME = -12.0
  VOLUME_RANGE = 0.5

  VOLUME_DETECT = -> (file_path) do
    <<-EOS
      ffmpeg -i #{file_path} -af "volumedetect" -vn -sn -dn -f null /dev/null 2>&1 |
      grep max_volume |
      cut -f 5 -d ' '
    EOS
  end

  VOLUME_ADJUST = -> (in_file_path, gain, out_file_path) do
      <<-EOS
      ffmpeg -i #{in_file_path} -af "volume=#{gain}dB" -y #{out_file_path} 2>&1
    EOS
  end

  def perform(intro_sound_id)
    # Set up files for ffmpeg
    in_file = Tempfile.new(['in', '.mp3'], binmode: true)
    out_file = Tempfile.new(['out', '.mp3'], binmode: true)

    # Get the sound file from mongo
    Rails.logger.info("Fetching intro sound #{intro_sound_id}")
    intro_sound = IntroSound.find(intro_sound_id)

    Rails.logger.info("Downloading sound file #{intro_sound.file_id}")
    original_sound_file = intro_sound.sound_file
    MongoFs.fs.download_to_stream(intro_sound.file_id, in_file)

    # Check the volume peak of the sound
    Rails.logger.info('Running ffmpeg volumedetect')
    command = VOLUME_DETECT.call(in_file.path)
    Rails.logger.info(command)
    peak_volume = `#{command}`.to_f

    Rails.logger.info("Got peak volume #{peak_volume}dB")
    diff = (TARGET_VOLUME - peak_volume).round 1

    # If it's already around -12dB, no need to do anything
    if diff.abs <= VOLUME_RANGE
      Rails.logger.info('No volume adjustment needed')
      return
    end

    # Otherwise, adjust the sound to a -12dB peak
    Rails.logger.info("Adjusting volume by #{diff}dB")
    command = VOLUME_ADJUST.call(in_file.path, diff, out_file.path)
    Rails.logger.info(command)
    result = `#{command}`

    if $?.success?
      Rails.logger.info('Volume adjusted')

      # Update the intro sound to point to the new adjusted sound file
      intro_sound.file_id = MongoFs.fs.upload_from_stream(original_sound_file['filename'], out_file)
      intro_sound.save
      Rails.logger.info("Created new file #{intro_sound.file_id}")

      MongoFs.fs.delete(original_sound_file['_id'])
      Rails.logger.info("Deleted old file #{original_sound_file['_id']}")
    else
      Rails.logger.error(
        "Volume adjustment for intro sound #{intro_sound.id} " +
        "(file #{original_sound_file['_id']}, #{original_sound_file['filename']} failed: " +
        "#{result}"
      )
    end
  ensure
    in_file&.unlink
    out_file&.unlink

    Rails.logger.info('Job done')
  end
end
