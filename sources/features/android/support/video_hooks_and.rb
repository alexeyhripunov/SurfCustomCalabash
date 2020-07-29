require 'open3'
require 'timeout'
require 'process'
require 'calabash-android/operations'
require 'calabash-android/env'

def adb_command
  "\"#{Calabash::Android::Dependencies.adb_path}\""
end

class ScreenRecord
  @@set = false
  @@screenrecord = nil

  def self.cmd
    return @@screenrecord if @@set
    out = Open3.capture2e("#{adb_command} shell screenrecord --help")
    @@set = true
    @@screenrecord =
        case out
          when /--bugreport/
            'screenrecord --bugreport'
          when /not found/
            nil
          else
            'screenrecord'
        end
  end
end

class AndroidVideoCapture

  def initialize
    @video_file = "video_#{Time.now.strftime('%d_%m-%H:%M:%S')}.mp4"
  end

  attr_reader :video_file

  def start_capture
    if ScreenRecord.cmd
      @screenrecord = Open3.popen2e("#{adb_command} shell")
      # for better quality video, increase the value of the bit-rate parameter,
      # or delete bit-rate parameter, video is recorded in high quality by default
      @screenrecord[0] << "#{ScreenRecord.cmd} --verbose --bit-rate 800000 /sdcard/#{@video_file} &\n"
      @screenrecord[0] << "CPID=$!\n"
    end
  end

  def stop_capture
    @screenrecord[0] << "if ps | grep screenrecord | grep $CPID; then kill -2 $CPID ; fi\n"
    begin
      Timeout.timeout(5) { @screenrecord[2].value }
    rescue Timeout::Error
      Process.detach(@screenrecord[2].pid)
    end
    @screenrecord[0].close
    @screenrecord[1].close
  end

  def dispose_capture
    system "#{adb_command} shell rm -f /sdcard/#{@video_file}"
  end

  def acquire_capture
    system "#{adb_command} pull /sdcard/#{@video_file} ./reports"
    dispose_capture
  end

end
