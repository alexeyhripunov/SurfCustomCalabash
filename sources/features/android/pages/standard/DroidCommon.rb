require 'calabash-android'
require 'SurfCustomCalabash/DroidMethods'

class DroidCommon

  # system methods
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
  def go_back
    sleep(1.5)
    press_back_button
    sleep(1)
  end

end

