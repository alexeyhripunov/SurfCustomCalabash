require 'calabash-cucumber/ibase'
require 'SurfCustomCalabash/CommonMethods'

# close keyboard with a swipe of the screen
def close_keyboard
  if keyboard_visible?
    pan_coordinates({x: 100, y: 150}, {x: 100, y: 250})
  end
end

# tap on Done on keyboard
def submit_keyboard
  if keyboard_visible?
    if element_exists("* marked:'Toolbar Done Button'")
      touch("* marked:'Toolbar Done Button'")
    else
      tap_keyboard_action_key
    end
  end
end

#----------------------------------------------Custom Swipe iOS-------------------------------------------------------
def strong_swipe(dir, sleep_duration: 0)
  if dir == 'left'
    swipe :left,  force: :strong
  elsif dir == 'right'
    swipe :right,  force: :strong
  elsif dir == 'up'
    swipe :down,  force: :strong
  elsif dir == 'down'
    swipe :up,  force: :strong
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def normal_swipe(dir, sleep_duration: 0)
  if dir == 'left'
    swipe :left,  force: :normal
  elsif dir == 'right'
    swipe :right,  force: :normal
  elsif dir == 'up'
    swipe :down,  force: :normal
  elsif dir == 'down'
    swipe :up,  force: :normal
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def light_swipe(dir, sleep_duration: 0)
  if dir == 'left'
    swipe :left,  force: :light
  elsif dir == 'right'
    swipe :right,  force: :light
  elsif dir == 'up'
    swipe :down,  force: :light
  elsif dir == 'down'
    swipe :up,  force: :light
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def strong_swipe_element(element, dir, sleep_duration: 0)
  if dir == 'left'
    swipe :left, :query => element, force: :strong
  elsif dir == 'right'
    swipe :right, :query => element, force: :strong
  elsif dir == 'up'
    swipe :down, :query => element, force: :strong
  elsif dir == 'down'
    swipe :up, :query => element, force: :strong
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def normal_swipe_element(element, dir, sleep_duration: 0)
  if dir == 'left'
    swipe :left, :query => element, force: :normal
  elsif dir == 'right'
    swipe :right, :query => element, force: :normal
  elsif dir == 'up'
    swipe :down, :query => element, force: :normal
  elsif dir == 'down'
    swipe :up, :query => element, force: :normal
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def light_swipe_element(element, dir, sleep_duration: 0)
  if dir == 'left'
    swipe :left, :query => element, force: :light
  elsif dir == 'right'
    swipe :right, :query => element, force: :light
  elsif dir == 'up'
    swipe :down, :query => element, force: :light
  elsif dir == 'down'
    swipe :up, :query => element, force: :light
  else
    p "Use direction 'up', 'down', 'left', 'right'"
  end
  sleep(sleep_duration)
end

def light_swipe_trait_until_exists(dir, element_destination, sleep_duration: 0, timeout_duration: 30)
  normal_swipe_until_exists(dir, element_destination, sleep_duration: sleep_duration, timeout_duration: timeout_duration)
end

# pull-to-refresh screen
def ptr
  pan_coordinates({x: 50, y: 100}, {x: 50, y: 600})
end

# touch on status bar -> scroll to up of the screen
def swipe_to_up
  touch(nil, :offset => {:x => 0, :y => 0})
end

# strong swipe to down of the screen
def swipe_to_down
  10.times {swipe :up,  force: :strong}
end

def back_swipe
  pan_coordinates({x:0, y:300}, {x:500, y:300})
end