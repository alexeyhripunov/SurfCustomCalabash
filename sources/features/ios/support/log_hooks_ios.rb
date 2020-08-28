require 'open3'
require 'timeout'
require 'process'
# require 'calabash-android/operations'
# require 'calabash-android/env'

def adb_command
  "\"#{Calabash::Android::Dependencies.adb_path}\""
end

class IosLogs

  def initialize
    @log_file = "#{ENV['SCREENSHOT_PATH']}log_#{Time.now.strftime('%d_%m-%H:%M:%S')}.txt"
  end

  attr_reader :log_file

  def start_log
    @logcat = Open3.popen2e("xcrun simctl spawn booted log stream")
    @pid = @logcat[2].pid
  end

  def stop_log
    @stoplog = Open3.popen2e("kill -SIGINT #{@pid}")

    begin
      Timeout.timeout(10) { File.open(@log_file, 'w') { |f| f << @logcat[1].readlines.join("\n") } }
    rescue Timeout::Error
      puts("Error write log file")
      @logcat[0].close
      @logcat[1].close
    end

    @stoplog[0].close
    @stoplog[1].close

    @logcat[0].close
    @logcat[1].close
  end

end
