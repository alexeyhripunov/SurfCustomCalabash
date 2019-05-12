require 'calabash-android'
require 'SurfCustomCalabash/CommonMethods'

# module DroidMethods
#   include Calabash::Android::Operations
#   include CommonMethods

  def close_keyboard
    if keyboard_visible?
      hide_soft_keyboard
    end
  end

  def submit_keyboard
    press_user_action_button
  end

  #----------------------------------------------Custom Android Swipe---------------------------------------------------
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

  # swipe trait-element from element_destination
  def light_swipe_trait_until_exists(dir, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{light_swipe_element(trait, dir)}, :timeout=>50)
  end

  # pull-to-refresh screen
  def ptr
    perform_action('drag', 50, 50, 15, 75, 4)
  end

# end