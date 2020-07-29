require 'calabash-android/operations'
require 'calabash-android/management/app_installation'
require 'calabash-android/cucumber'
require 'cucumber'
require 'json'

Before do |scenario|

  ENV['SCREENSHOT_PATH'] = './reports/'

  @scenario_name = scenario.name

  scenario_tags = scenario.source_tag_names
  if scenario_tags.include?('@reinstall')
    reinstall_apps
  end

  if scenario_tags.include?('@clear')
    clear_app_data
  end

  if scenario_tags.include?('@skip')
    skip_this_scenario('Сценарий только для iOS')
  end

  start_test_server_in_background

  @video_capture = nil
  @video_capture = AndroidVideoCapture.new
  @video_capture.start_capture

  @write_log = nil
  @write_log = AndroidLogs.new
  @write_log.start_log
end

def file_name(ext)
  "android_#{Time.now.strftime('%d_%m-%H:%M:%S')}.#{ext}"
end

After do |scenario|

  @video_capture.stop_capture
  @write_log.stop_log

  if scenario.failed?

    # device= %x(adb devices | awk 'NR==2{print $1} /device:/')
    model = %x(adb devices -l | awk 'NR==2{print $5}')

    model.slice! "model:"

    path =  "#{ENV['SCREENSHOT_PATH']}#{@scenario_name}_#{model}_#{Time.now.strftime('%d_%m-%H:%M:%S')}/"
    Dir.mkdir(path) unless File.directory?(path)

    pretty = JSON.pretty_generate(query("*"))
    parsed = JSON.parse(pretty)

    for i in 0..query("*").count-1
      id = parsed[i]['id'].to_s
      text = parsed[i]['text'].to_s
      if id != ''
        File.open("#{path}id_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(id.encode(crlf_newline: true))}
      end
      if text != ''
        File.open("#{path}text_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(text.encode(crlf_newline: true))}
      end
    end

    @video_capture.acquire_capture

    screenshot(:prefix => path, :name => "#{file_name('png')}")

    video_path = "#{ENV['SCREENSHOT_PATH']}#{@video_capture.video_file}"
    if File.exist?(video_path)
      embed(video_path, 'video/mp4', "video #{video_path}")
      FileUtils.mv(video_path, path)
    end

    if File.exist?(@write_log.log_file)
      embed(@write_log.log_file, 'log/txt', "log #{@write_log.log_file}")
      FileUtils.mv(@write_log.log_file, path)
    end
  end


  if scenario.passed?
    @video_capture.dispose_capture
    File.delete(@write_log.log_file)
  end

  shutdown_test_server

end