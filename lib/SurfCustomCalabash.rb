require "SurfCustomCalabash/version"

module SurfCustomCalabash
  class Error < StandardError; end
  # Your code goes here...
  require 'SurfCustomCalabash/DroidMethods'
  require 'SurfCustomCalabash/IosMethods'
  require 'SurfCustomCalabash/CommonMethods'
end
