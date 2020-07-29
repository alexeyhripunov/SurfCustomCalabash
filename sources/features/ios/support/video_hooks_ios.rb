require 'open3'
require 'timeout'

class IosCapture

  def initialize
    @video_file = "#{ENV['SCREENSHOT_PATH']}video_#{Time.now.strftime('%d_%m-%H:%M:%S')}.mp4"
  end

  attr_reader :video_file

  def start_capture
    @screenrecord = Open3.popen2e("xcrun simctl io booted recordVideo #{@video_file} \n")
    @pid = @screenrecord[2].pid
    puts("start record")
  end

  def stop_capture
    @stoprecord = Open3.popen2e("kill -SIGINT #{@pid}")

    @screenrecord[0].close
    @screenrecord[1].close

    @stoprecord[0].close
    @stoprecord[1].close
  end

end
