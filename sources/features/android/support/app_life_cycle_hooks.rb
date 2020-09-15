require 'calabash-android/operations'
require 'calabash-android/management/app_installation'
require 'calabash-android/cucumber'
require 'cucumber'
require 'json'
require_relative '../../../features/net/screentest_api'
require 'fileutils'

Before do |scenario|

  ENV['SCREENSHOT_PATH'] = './reports/'

  @scenario_name = scenario.name

  @start_record = true
  @start_log = true

  scenario_tags = scenario.source_tag_names

  reinstall_apps if scenario_tags.include?('@reinstall')

  clear_app_data if scenario_tags.include?('@clear')

  skip_this_scenario('Сценарий только для iOS') if scenario_tags.include?('@skip')

  if scenario_tags.include?('@screentest')
    clear_file_with_stack_trace
    create_feature(@scenario_name)
  end

  @start_record = true if scenario_tags.include?('@record')

  start_test_server_in_background

  @video_capture = nil

  # start video record
  if @start_record
    @video_capture = AndroidVideoCapture.new
    @video_capture.start_capture
    @need_convert = false
    # set video quality: low, medium, high
    @video_capture.quality = "low"
  end

  @write_log = nil

  # start write logs
  if @start_log
    @write_log = AndroidLogs.new
    @write_log.start_log
  end
end

def file_name(ext)
  "android_#{Time.now.strftime('%d_%m-%H:%M:%S')}.#{ext}"
end

def create_folder
  model = %x(adb devices -l | awk 'NR==2{print $5}')
  model.slice! "model:"

  @path =  "#{ENV['SCREENSHOT_PATH']}#{@scenario_name}_#{model}_#{Time.now.strftime('%d_%m-%H:%M:%S')}/"
  # Dir.mkdir(@path) unless File.directory?(@path)
  FileUtils.mkdir_p @path
end

def convert
  convert_file = "video_#{file_name('mp4')}"
  @video_capture.convert_video(@video_capture.video_file, convert_file)
  delete_file(@video_capture.video_file)
  @video_capture.video_file = convert_file
end

def embed_video
  unless @video_capture.nil?
    @video_capture.acquire_capture
    if File.exist?(@video_capture.video_file)
      convert if @need_convert
      embed(@video_capture.video_file, 'video/mp4', "video #{@video_capture.video_file}")
      FileUtils.mv(@video_capture.video_file, @path)
      @video_capture.video_file = @path + @video_capture.video_file
    end
  end
end

def delete_file(file_name)
  if File.exist?(file_name)
    File.delete(file_name)
  end
end

def embed_logs
  unless @write_log.nil?
    if File.exist?(@write_log.log_file)
      embed(@write_log.log_file, 'log/txt', "log #{@write_log.log_file}")
      FileUtils.mv(@write_log.log_file, @path)
    end
  end
end

After do |scenario|

  @video_capture.stop_capture unless @video_capture.nil?

  @write_log.stop_log unless @write_log.nil?

  scenario_tags = scenario.source_tag_names

  if scenario_tags.include?('@record') && scenario.passed?
    create_folder
    embed_video
  elsif scenario.passed?
    @video_capture.dispose_capture unless @video_capture.nil?
    delete_file(@write_log.log_file) unless @write_log.nil?
    delete_file(@video_capture.video_file) unless @video_capture.nil?
  end

  if scenario.failed?

    create_folder

    mark_feature_as_not_finished if scenario.source_tag_names.include?('@screentest')

    pretty = JSON.pretty_generate(query("*"))
    parsed = JSON.parse(pretty)

    for i in 0..query("*").count-1
      id = parsed[i]['id'].to_s
      text = parsed[i]['text'].to_s
      if id != ''
        File.open("#{@path}id_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(id.encode(crlf_newline: true))}
      end
      if text != ''
        File.open("#{@path}text_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(text.encode(crlf_newline: true))}
      end
    end

    screenshot(prefix: @path, name: "#{file_name('png')}")
    embed_video
    embed_logs
  end
  
  send_video(@video_capture.video_file) if scenario.source_tag_names.include?('@record')
  shutdown_test_server

end
