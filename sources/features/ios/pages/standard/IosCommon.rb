require 'calabash-cucumber/ibase'
require 'SurfCustomCalabash/IosMethods'


class IosCommon < Calabash::IBase

  # system method
  def initialize(driver)
    @driver = driver
  end

  def method_missing (sym, *args, &block)
    @driver.send sym, *args, &block
  end

  def self.element(name, &block)
    define_method(name.to_s, &block)
  end

  class << self
    alias :value    :element
    alias :action   :element
    alias :trait    :element
  end

  # custom methods

end


