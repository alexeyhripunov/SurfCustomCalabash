if ENV['PLATFORM'] == 'ios'
  require 'calabash-cucumber/cucumber'
  require_relative '../ios/pages/standard/IosCommon'
elsif ENV['PLATFORM'] == 'android'
  require 'calabash-android/cucumber'
  require_relative '../../features/android/pages/standard/DroidCommon'
end

