require 'calabash-android'
require 'SurfCustomCalabash/CommonMethods'

# close keyboard, parameters use ios only
def close_keyboard(x_start: 0, y_start:0)
  if keyboard_visible?
    hide_soft_keyboard
  end
end

def submit_keyboard
  press_user_action_button
end

#----------------------------------------------Custom Android Swipe---------------------------------------------------
def strong_swipe(dr, sleep_duration: 0)
  if dr == "up"
    perform_action('drag', 50, 50, 15, 75, 25)
  elsif dr == "down"
    perform_action('drag', 50, 50, 75, 15, 25)
  elsif dr == "left"
    perform_action('drag', 90, 0, 50, 50, 10)
  elsif dr == "right"
    perform_action('drag', 0, 90, 50, 50, 10)
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def normal_swipe(dr, sleep_duration: 0)
  if dr == "up"
    perform_action('drag', 50, 50, 15, 45, 25)
  elsif dr == "down"
    perform_action('drag', 50, 50, 45, 15, 25)
  elsif dr == "left"
    perform_action('drag', 50, 0, 50, 50, 10)
  elsif dr == "right"
    perform_action('drag', 0, 50, 50, 50, 10)
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def light_swipe(dr, sleep_duration: 0)
  if dr == "up"
    perform_action('drag', 50, 50, 15, 30, 25)
  elsif dr == "down"
    perform_action('drag', 50, 50, 30, 15, 25)
  elsif dr == "left"
    perform_action('drag', 25, 0, 50, 50, 10)
  elsif dr == "right"
    perform_action('drag', 0, 25, 50, 50, 10)
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def strong_swipe_element(element, dir, sleep_duration: 0)
  if dir == 'left'
    flick(element, :left)
  elsif  dir == 'right'
    flick(element, :right)
  elsif dir == 'down'
    flick(element, :up)
  elsif dir == 'up'
    flick(element, :down)
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def normal_swipe_element(element, dir, sleep_duration: 0)
  if dir == 'left'
    pan(element, :left)
  elsif  dir == 'right'
    pan(element, :right)
  elsif dir == 'down'
    pan(element, :up)
  elsif dir == 'up'
    pan(element, :down)
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def light_swipe_element(element, dir, sleep_duration: 0)
  if dir == 'left'
    pan(element, :left)
  elsif  dir == 'right'
    pan(element, :right)
  elsif dir == 'down'
    pan(element, :up)
  elsif dir == 'up'
    pan(element, :down)
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

# swipe trait-element from element_destination
def light_swipe_trait_until_exists(dir, element_destination, sleep_duration: 0, timeout_duration: 30)
  light_swipe_element_until_exists(dir, trait, element_destination, sleep_duration: sleep_duration, timeout_duration: timeout_duration)
end

# pull-to-refresh screen
def ptr
  perform_action('drag', 50, 50, 15, 75, 4)
end

# strong swipe to up of the screen
def swipe_to_up
  5.times {perform_action('drag', 50, 50, 15, 70, 1)}
end

# strong swipe to down of the screen
def swipe_to_down
  5.times {perform_action('drag', 50, 50, 60, 10, 1)}
end