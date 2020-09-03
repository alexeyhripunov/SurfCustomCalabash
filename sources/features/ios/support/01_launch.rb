require 'calabash-cucumber/launcher'
require 'calabash-cucumber/cucumber'
require_relative '../../support/env'
require_relative '../../../features/net/screentest_api'
require 'fileutils'


module Calabash::Launcher
  @@launcher = nil

  def self.launcher
    @@launcher ||= Calabash::Cucumber::Launcher.new
  end

  def self.launcher=(launcher)
    @@launcher = launcher
  end
end


Before ('@reinstall') do
  ENV['RESET_BETWEEN_SCENARIOS'] = '1'
end

Before('@screentest') do |scenario|

  clear_file_with_stack_trace
  @scenario_name = scenario.name
  create_feature(@scenario_name)

end


Before  do |scenario|

  begin
    calabash_exit
  rescue HTTPClient::ReceiveTimeoutError => e
    puts(e)
  end
  
  ENV['SCREENSHOT_PATH'] = './reports/'

  scenario_tags = scenario.source_tag_names

  @start_record = true
  @start_log = false

  # Scenario name
  @scenario_name = scenario.name

  launcher = Calabash::Launcher.launcher
  options = {
      # Add launch options here.
  }

  launcher.relaunch(:timeout => 300)
  ENV['RESET_BETWEEN_SCENARIOS'] = ''

  if scenario_tags.include?('@record')
    @start_record = true
  end

  @video_capture = nil

  # start record video
  if @start_record
    @video_capture = IosCapture.new
    @video_capture.start_capture
    @need_convert = false
    # set video quality: low, medium, high
    @video_capture.quality = "low"
  end

  @write_log = nil

  # start write logs
  if @start_log
    @write_log = IosLogs.new
    @write_log.start_log
  end
end

After do
  # Calabash can shutdown the app cleanly by calling the app life cycle methods
  # in the UIApplicationDelegate.  This is really nice for CI environments, but
  # not so good for local development.
  #
  # See the documentation for QUIT_APP_AFTER_SCENARIO for a nice debugging workflow
  #
  # http://calabashapi.xamarin.com/ios/file.ENVIRONMENT_VARIABLES.html#label-QUIT_APP_AFTER_SCENARIO
  # http://calabashapi.xamarin.com/ios/Calabash/Cucumber/Core.html#console_attach-instance_method

  begin
    calabash_exit
  rescue HTTPClient::ReceiveTimeoutError => e
    puts(e)
  end

end

def file_name(ext)
  "iOS_#{Time.now.strftime('%d_%m-%H:%M:%S')}.#{ext}"
end

def create_folder
  @path =  "#{ENV['SCREENSHOT_PATH']}#{@scenario_name}_#{Time.now.strftime('%d_%m-%H:%M:%S')}/"
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
    if File.exist?(@video_capture.video_file)
      convert if @need_convert
      sleep(2)
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
    # puts("file name #{@video_capture.video_file}")
  elsif scenario.passed?
    delete_file(@write_log.log_file) unless @write_log.nil?
    delete_file(@video_capture.video_file) unless @video_capture.nil?
  end

  if scenario.failed?

    create_folder
    mark_feature_as_not_finished if scenario_tags.include?('@screentest')

    pretty = JSON.pretty_generate(query("*"))
    parsed = JSON.parse(pretty)

    for i in 0..query("*").count-1
      id = parsed[i]['id'].to_s
      text = parsed[i]['text'].to_s
      label = parsed[i]['label'].to_s
      if id != ''
        File.open("#{@path}id_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(id.encode(crlf_newline: true))}
      end
      if text != ''
        File.open("#{@path}text_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(text.encode(crlf_newline: true))}
      end
      if label != ''
        File.open("#{@path}label_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(label.encode(crlf_newline: true))}
      end
    end

    screenshot(prefix: @path, name: "#{file_name('png')}")

    embed_video
    embed_logs
  end

  send_video(@video_capture.video_file) if scenario_tags.include?('@record')

end
