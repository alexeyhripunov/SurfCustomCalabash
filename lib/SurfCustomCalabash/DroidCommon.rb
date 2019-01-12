require 'calabash-android'
require 'rspec/expectations'
require 'SurfCustomCalabash/CommonMethods'

class DroidCommon

  include Calabash::Android::Operations
  include CommonMethods

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

  def close_keyboard
    if keyboard_visible?
      hide_soft_keyboard
    end
  end

  #----------------------------------------------свайпы всех видов------------------------------------------------------
  # простой свайп
  def strong_swipe(dr)
    if dr == "up"
      perform_action('drag', 50, 50, 15, 75, 4)
    elsif dr == "down"
      perform_action('drag', 50, 50, 60, 5, 1)
    elsif dr == "left"
      perform_action('drag', 90, 0, 50, 50, 10)
    elsif dr == "right"
      perform_action('drag', 0, 90, 50, 50, 10)
    end
  end

  def normal_swipe(dr)
    if dr == "up"
      perform_action('drag', 50, 50, 45, 80, 10)
    elsif dr == "down"
      perform_action('drag', 50, 50, 80, 45, 10)
    end
  end

  def light_swipe(dr)
    if dr == "down"
      perform_action('drag', 50, 50, 80, 70, 10)
    elsif dr == "up"
      perform_action('drag', 50, 50, 70, 80, 5)
    end
  end

  # свайп элемента
  def strong_swipe_element(element, dir)
    if dir == 'left'
      flick(element, :left)
    elsif  dir == 'right'
      flick(element, :right)
    elsif dir == 'down'
      flick(element, :up)
    elsif dir == 'up'
      flick(element, :down)
    end
  end

  def normal_swipe_element(element, dir)
    if dir == 'left'
      pan(element, :left)
    elsif  dir == 'right'
      pan(element, :right)
    elsif dir == 'down'
      pan(element, :up)
    elsif dir == 'up'
      pan(element, :down)
    end
  end

  def light_swipe_element(element, dir)
    if dir == 'left'
      pan(element, :left)
    elsif  dir == 'right'
      pan(element, :right)
    elsif dir == 'down'
      pan(element, :up)
    elsif dir == 'up'
      pan(element, :down)
    end
  end

  def ptr
    perform_action('drag', 50, 50, 15, 75, 4)
  end



end