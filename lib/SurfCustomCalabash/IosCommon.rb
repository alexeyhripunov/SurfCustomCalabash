require 'calabash-cucumber/ibase'
require 'SurfCustomCalabash/CommonMethods'

class IosCommon < Calabash::IBase

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

  #----------------------------------------------свайпы всех видов------------------------------------------------------
  # простой свайп
  def strong_swipe(dir)
    if dir == 'left'
      swipe :left,  force: :strong
    elsif dir == 'right'
      swipe :right,  force: :strong
    elsif dir == 'up'
      swipe :down,  force: :strong
    elsif dir == 'down'
      swipe :up,  force: :strong
    end
  end

  def normal_swipe(dir)
    if dir == 'left'
      swipe :left,  force: :normal
    elsif dir == 'right'
      swipe :right,  force: :normal
    elsif dir == 'up'
      swipe :down,  force: :normal
    elsif dir == 'down'
      swipe :up,  force: :normal
    end
  end

  def light_swipe(dir)
    if dir == 'left'
      swipe :left,  force: :light
    elsif dir == 'right'
      swipe :right,  force: :light
    elsif dir == 'up'
      swipe :down,  force: :light
    elsif dir == 'down'
      swipe :up,  force: :light
    end
  end

  # свайп элемента
  def strong_swipe_element(element, dir)
    if dir == 'left'
      swipe :left, :query => element, force: :strong
    elsif dir == 'right'
      swipe :right, :query => element, force: :strong
    elsif dir == 'up'
      swipe :down, :query => element, force: :strong
    elsif dir == 'down'
      swipe :up, :query => element, force: :strong
    end
  end

  def normal_swipe_element(element, dir)
    if dir == 'left'
      swipe :left, :query => element, force: :normal
    elsif dir == 'right'
      swipe :right, :query => element, force: :normal
    elsif dir == 'up'
      swipe :down, :query => element, force: :normal
    elsif dir == 'down'
      swipe :up, :query => element, force: :normal
    end
  end

  def light_swipe_element(element, dir)
    if dir == 'left'
      swipe :left, :query => element, force: :light
    elsif dir == 'right'
      swipe :right, :query => element, force: :light
    elsif dir == 'up'
      swipe :down, :query => element, force: :light
    elsif dir == 'down'
      swipe :up, :query => element, force: :light
    end
  end

  # выбрать дату в дата пикере
  def enter_date
    wait_for_element_exists("datePicker", :timeout=>5)
    target_date = Date.parse("July 28 2017")
    date_time = DateTime.new(target_date.year, target_date.mon, target_date.day)
    picker_set_date_time date_time
  end

  def ptr
    swipe(:down, :offset => {:x => 0, :y => -200})
  end


end