require 'open3'
require 'timeout'
require 'process'
require 'calabash-android/operations'
require 'calabash-android/env'
require 'streamio-ffmpeg'

def adb_command
  "\"#{Calabash::Android::Dependencies.adb_path}\""
end

class ScreenRecord

  # определяем поддерживает ли устройсвто запись через adb или scrcpy
  def self.get_adb_or_scr
    if Open3.capture2e("#{adb_command} shell screenrecord --help").first.include? "Options:"
      return "adb"
    elsif Open3.capture2e("scrcpy --help").first.include? "Options:"
      return "scrcpy"
    else
      return "adb and scrcpy not install"
    end
  end
end

class AndroidVideoCapture

  def initialize
    @video_file = "video_#{Time.now.strftime('%d_%m-%H:%M:%S')}.mp4"

    # определяем поддерживает ли устройсвто запись через adb или scrcpy
    @command = ScreenRecord.get_adb_or_scr

    # качество видео при конвертации
    @quality = "low"
  end

  attr_accessor :video_file, :quality

  # запускаем запись видео
  def start_capture
    if @command == "adb"
      @screenrecord = Open3.popen2e("#{adb_command} shell")
      # для улучшения качества видео, увеличить битрейт или убрать параметр совсем, по умолчанию пишется в хорошем качестве
      @screenrecord[0] << "screenrecord --verbose --bit-rate 1000000 /sdcard/#{@video_file} &\n"
      @screenrecord[0] << "CPID=$!\n"
    elsif @command == "scrcpy"
      @screenrecord = Open3.popen2e("scrcpy -m 1024 -b 2M --max-fps 10 -Nr #{@video_file}")
      @pid = @screenrecord[2].pid
    end
  end

  # останавливаем запись видео
  def stop_capture

    if @command == "adb"
      @screenrecord[0] << "if ps | grep screenrecord | grep $CPID; then kill -2 $CPID ; fi\n"
    elsif @command == "scrcpy"
      %x{kill -SIGINT #{@pid}}
    end

    begin
      Timeout.timeout(5) { @screenrecord[2].value }
    rescue Timeout::Error
      Process.detach(@screenrecord[2].pid)
    end

    @screenrecord[0].close
    @screenrecord[1].close

  end

  # удаляем видео с устройства если была запись через adb
  def dispose_capture
    system "#{adb_command} shell rm -f /sdcard/#{@video_file}" if @command == "adb"
  end

  # сбрасываем видео с устройства в папку с тестами
  def acquire_capture
    if @command == "adb"
      system "#{adb_command} pull /sdcard/#{@video_file} ."
      dispose_capture
    end
  end

  # конвертируем видео
  def convert_video(path_to_input, path_to_output, quality = @quality)
    movie = FFMPEG::Movie.new(path_to_input)

    Kernel.puts "size #{movie.size}"

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
