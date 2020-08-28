require 'open3'
require 'timeout'
require 'streamio-ffmpeg'

class IosCapture

  def initialize
    @video_file = "video_#{Time.now.strftime('%d_%m-%H_%M_%S')}.mp4"

    @quality = "low"

    # h264 or hevc
    @codec = "hevc"
  end

  attr_accessor :video_file, :quality

  def start_capture(codec = @codec)
    @screenrecord = Open3.popen2e("xcrun simctl io booted recordVideo --codec=#{codec} #{@video_file} \n")
    # @screenrecord = Open3.popen2e("xcrun simctl io booted recordVideo #{@video_file} \n")
    @pid = @screenrecord[2].pid
    puts("start record")
  end

  def stop_capture
    @stoprecord = Open3.popen2e("kill -SIGINT #{@pid}")

    @screenrecord[0].close
    @screenrecord[1].close

    @stoprecord[0].close
    @stoprecord[1].close

    puts("video stopped")
  end

  def convert_video(path_to_input, path_to_output, quality = @quality)
    movie = FFMPEG::Movie.new(path_to_input)

    options = {video_codec: "h264", frame_rate: '10', resolution: "320x180"}
    transcoder_options = {preserve_aspect_ratio: :width}

    case quality.downcase
      when "low"
        options.merge!({video_bitrate: 100})
      when "medium"
        options.merge!({video_bitrate: 500})
      when "high"
        options.merge!({resolution: "720x480", video_bitrate: 1000})
      else
        return p "Please set video quality: high, medium or low"
    end

    Timeout.timeout(60) {
      movie.transcode(path_to_output, options, transcoder_options)
    }
  end
end
