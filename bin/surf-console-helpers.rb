#!/usr/bin/env ruby

require 'fileutils'
require 'rbconfig'

def android_console(app_path = nil)
  test_server_path = test_server_path(app_path)

  path = ENV['CALABASH_IRBRC']

  unless path
    if File.exist?('irbrc')
      path = File.expand_path('irbrc')
    end
  end

  unless path
    path = File.expand_path(File.join(File.dirname(__FILE__), '../sources/irbrcs/android', 'irbrc'))
  end

  ENV['IRBRC'] = path
  Kernel.puts(path)

  unless ENV['APP_PATH']
    ENV['APP_PATH'] = app_path
  end

  unless ENV['TEST_APP_PATH']
    ENV['TEST_APP_PATH'] = test_server_path
  end

  build_test_server_if_needed(app_path)

  Kernel.puts 'Starting calabash-android console...'
  Kernel.puts "Loading #{ENV['IRBRC']}"
  Kernel.puts 'Running irb...'
  exec('irb')
end

def is_apk_file?(file_path)
  file_path.end_with? ".apk" and File.exist? file_path
end

def relative_to_full_path(file_path)
  File.expand_path(file_path)
end

def ios_console
  path = ENV['CALABASH_IRBRC']
  unless path
    if File.exist?('.irbrc')
      path = File.expand_path('.irbrc')
    end
  end
  unless path
    path = File.expand_path(File.join(File.dirname(__FILE__), '../sources/irbrcs/ios', 'irbrc'))
  end
  ENV['IRBRC'] = path
  Kernel.puts "Running irb..."
  exec("irb")
end
