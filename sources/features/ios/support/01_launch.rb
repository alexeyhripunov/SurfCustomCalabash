require 'calabash-cucumber/launcher'
require 'calabash-cucumber/cucumber'
require_relative '../../support/env'
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

Before  do |scenario|

  begin
    calabash_exit
  rescue HTTPClient::ReceiveTimeoutError => e
    puts(e)
  end

  ENV['SCREENSHOT_PATH'] = './reports/'

  # Scenario name
  @scenario_name = scenario.name

  launcher = Calabash::Launcher.launcher
  options = {
      # Add launch options here.
  }

  launcher.relaunch(:timeout => 300)
  ENV['RESET_BETWEEN_SCENARIOS'] = ''

  # start record video
  @video_capture = nil
  @video_capture = IosCapture.new
  @video_capture.start_capture

  @write_log = nil
  @write_log = IosLogs.new
  @write_log.start_log
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

After do |scenario|

  @video_capture.stop_capture
  @write_log.stop_log

  if scenario.failed?

    path =  "#{ENV['SCREENSHOT_PATH']}#{@scenario_name}_#{Time.now.strftime('%d_%m-%H:%M:%S')}/"
    Dir.mkdir(path) unless File.directory?(path)

    pretty = JSON.pretty_generate(query("*"))
    parsed = JSON.parse(pretty)

    for i in 0..query("*").count-1
      id = parsed[i]['id'].to_s
      text = parsed[i]['text'].to_s
      label = parsed[i]['label'].to_s
      if id != ''
        File.open("#{path}id_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(id.encode(crlf_newline: true))}
      end
      if text != ''
        File.open("#{path}text_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(text.encode(crlf_newline: true))}
      end
      if label != ''
        File.open("#{path}label_#{file_name('txt')}", 'a', crlf_newline: true) { |f| f.puts(label.encode(crlf_newline: true))}
      end
    end

    screenshot(:prefix => path, :name => "#{file_name('png')}")

    if File.exist?(@video_capture.video_file)
      embed(@video_capture.video_file, 'video/mp4', "video #{@video_capture.video_file}")
      FileUtils.mv(@video_capture.video_file, path)
    end

    if File.exist?(@write_log.log_file)
      embed(@write_log.log_file, 'log/txt', "log #{@write_log.log_file}")
      FileUtils.mv(@write_log.log_file, path)
    end
  end

  if scenario.passed?
    File.delete(@write_log.log_file)
    File.delete(@video_capture.video_file)
  end
end
