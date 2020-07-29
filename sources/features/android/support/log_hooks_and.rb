require 'open3'
require 'timeout'
require 'process'
require 'calabash-android/operations'
require 'calabash-android/env'

def adb_command
  "\"#{Calabash::Android::Dependencies.adb_path}\""
end

class AndroidLogs

  def initialize
    @log_file = "#{ENV['SCREENSHOT_PATH']}log_#{Time.now.strftime('%d_%m-%H:%M:%S')}.txt"
  end

  attr_reader :log_file

  def start_log
    package = package_name('L.apk')
    pid_app = %x{adb shell ps | grep #{package} | tr -s [:space:] ' ' | cut -d' ' -f2}
    @logcat = Open3.popen2e("adb logcat | grep #{pid_app}")
    @pid = @logcat[2].pid
  end

  def stop_log
    %x{ps | grep logcat | grep -v grep | cut -d' ' -f1 | awk '{print $1}' | xargs kill -2}

    begin
      Timeout.timeout(5) { File.open(@log_file, 'w') { |f| f << @logcat[1].readlines.join("\n") } }
    rescue Timeout::Error
      puts("Error write log file")
      @logcat[0].close
      @logcat[1].close
    end

    @logcat[0].close
    @logcat[1].close
  end

end
