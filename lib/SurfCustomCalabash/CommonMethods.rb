require 'rspec/expectations'

  def enter_text_from_keyboard(text)
    wait_for_keyboard(:timeout=>5)
    keyboard_enter_text(text)
  end

  # ----------------------------------------------Custom Taps-----------------------------------------------------------
  # wait element and tap
  def tap_on(element, timeout_duration: 15, sleep_duration: 0.5)
    wait_element(element, timeout_duration: timeout_duration, sleep_duration: sleep_duration, retry_frequency: 5)
    touch(element)
  end

  def tap_on_text(text)
    tap_on("* {text CONTAINS'#{text}'}")
  end

  # if element exists - tap, if not - swipe until element exists and tap
  def tap_or_swipe(element, timeout_duration: 30, sleep_duration: 2)
    if element_exists(element)
      sleep(sleep_duration)
      touch(element)
    else
      until_element_exists(element,:action => lambda{light_swipe('down')},  :timeout => timeout_duration)
      light_swipe('down')
      sleep(sleep_duration)
      touch(element)
    end
  end

  # ----------------------------------------------------Custom Waits----------------------------------------------------
  def wait_element(element, timeout_duration: 15, sleep_duration: 0, retry_frequency: 0.3)
    wait_for_element_exists(element, :timeout=>timeout_duration, :retry_frequency=>retry_frequency)
    sleep(sleep_duration)
  end

  def wait_no_element(element, timeout_duration: 15, sleep_duration: 0, retry_frequency: 0.3)
    wait_for_element_does_not_exist(element, :timeout=>timeout_duration, :retry_frequency=>retry_frequency)
    sleep(sleep_duration)
  end

  # wait trait-element on screen
  def wait_for_screen(timeout_duration: 25, sleep_duration: 0)
    wait_for_elements_exist(trait, :timeout=>timeout_duration)
    sleep(sleep_duration)
  end

  # ----------------------------------------------------Custom Swipe----------------------------------------------------
  def strong_swipe_until_not_exist(dir, element_destination, timeout_duration: 40)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{strong_swipe(dir)}, :timeout => timeout_duration)
  end

  def normal_swipe_until_not_exist(dir, element_destination, timeout_duration: 40)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{normal_swipe(dir)}, :timeout => timeout_duration)
  end

  def light_swipe_until_not_exist(dir, element_destination, timeout_duration: 40)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{light_swipe( dir)}, :timeout => timeout_duration)
  end

  def strong_swipe_until_exists(dir, element_destination, timeout_duration: 40)
    until_element_exists(element_destination,
                         :action =>  lambda{strong_swipe( dir)}, :timeout => timeout_duration)
  end

  def normal_swipe_until_exists(dir, element_destination, sleep_duration: 2, timeout_duration: 40)
    until_element_exists(element_destination,
                         :action =>  lambda{normal_swipe( dir); sleep(sleep_duration)}, :timeout=>timeout_duration)
  end

  def light_swipe_until_exists(dir, element_destination, sleep_duration: 2, timeout_duration: 40)
    until_element_exists(element_destination,
                         :action =>  lambda{light_swipe( dir); sleep(sleep_duration)}, :timeout=>timeout_duration)

  end

  def strong_swipe_element_until_exists(dir, element, element_destination, timeout_duration: 40)
    until_element_exists(element_destination,
                         :action =>  lambda{strong_swipe_element(element, dir)}, :timeout=>timeout_duration)
  end

  def light_swipe_element_until_exists(dir, element, element_destination, timeout_duration: 40)
    until_element_exists(element_destination,
                         :action =>  lambda{light_swipe_element(element, dir)}, :timeout=>timeout_duration)
  end

  def strong_swipe_element_until_not_exists(dir, element, element_destination, timeout_duration: 40)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{pan(element, dir)}, :timeout=>timeout_duration)
  end

  def light_swipe_element_until_not_exists(dir, element, element_destination, timeout_duration: 40)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{light_swipe_element(element, dir)}, :timeout=>timeout_duration)
  end

  def swipe_to_text(dir, text, timeout_duration: 60)
    sleep(1)
    if dir == 'up'
      until_element_exists("* {text CONTAINS'#{text}'}", :action =>  lambda{light_swipe('up');
      sleep(1)}, :timeout => timeout_duration)
    elsif dir == 'down'
      until_element_exists("* {text CONTAINS'#{text}'}", :action =>  lambda{light_swipe('down');
      sleep(1.5)}, :timeout => timeout_duration)
    end
  end

  # -------------------------------------------------Asserts------------------------------------------------------------
  def assert_eql_with_rescue(element1, element2)
    begin
      expect(element1).to eq(element2)
      true
    rescue RSpec::Expectations::ExpectationNotMetError
      false
    end
  end

  def assert_eql(element1, element2)
    expect(element1).to eq(element2)
  end

  def assert_not_eql(element1, element2)
    expect(element1).not_to eql(element2)
  end

  def assert_true(element)
    expect(element).to be true
  end

  def assert_false(element)
    expect(element).to be false
  end

  def assert_nil(element)
    expect(element).to be_nil
  end

  # ------------------------------------------Generate String-----------------------------------------------------------
  def get_random_num_string(length)
    source=(0..9).to_a
    key=""
    length.times{ key += source[rand(source.size)].to_s }
    return key
  end

  def get_random_text_string(length)
    source=("a".."z").to_a
    key=""
    length.times{ key += source[rand(source.size)].to_s }
    return key
  end

  def get_random_email
    return get_random_text_string(7) + "@" + get_random_text_string(2) + ".test"
  end

  # get first digital from string
  def extract_num_from_str(text)
    text.gsub!(/[[:space:]]/, '')
    num = text.scan(/\d+/).first.nil? ? "0" : text.scan(/\d+/).first
    p num
  end

  # get last digital from string
  def extract_last_num_from_str(text)
    text.gsub!(/[[:space:]]/, '')
    num = text.scan(/\d+/).first.nil? ? "0" : text.scan(/\d+/).last
    p num
  end

  # get text from first element
  def remember(element, timeout_duration: 5)
    wait_for_element_exists(element, :timeout => timeout_duration)
    sleep(1.5)
    name = query(element)
    save_name = name.first['text']
    puts(save_name)
    return save_name
  end

  # get text from last element
  def remember_last_text(element, timeout_duration: 5)
    wait_for_element_exists(element, :timeout => timeout_duration)
    sleep(1.5)
    name = query(element)
    save_name = name.last['text']
    puts(save_name)
    return save_name
  end

  # wait text
  def check_text(text, timeout_duration: 5)
    wait_for_element_exists("* {text CONTAINS'#{text}'}", :timeout => timeout_duration, :retry_frequency => 2)
  end

  def no_check_text(text, timeout_duration: 5)
    wait_for_element_does_not_exist("* {text CONTAINS'#{text}'}", :timeout => timeout_duration, :retry_frequency => 5)
  end

  # get element's coordinates
  def get_coordinate_x(element)
    el = query(element)
    coordinate = el[0]['rect']['center_x']
    # puts(coordinate)
    return coordinate.to_i
  end

  def get_coordinate_y(element)
    el = query(element)
    coordinate = el[0]['rect']['center_y']
    # puts(coordinate)
    return coordinate.to_i
  end

  # Drag element from one place to place of other element
  def drag_element(element_from , element_to)
    x_from = get_coordinate_x(element_from)
    y_from = get_coordinate_y(element_from)

    x_to = get_coordinate_x(element_to)
    y_to = get_coordinate_y(element_to)
    drag_coordinates(x_from, y_from, x_to, y_to, 10, 0.5, 0.5)
  end

  # if elements cross - return true, if not - false
  def cross_coordinate(element_front, element_behind)
    cross = false

    if element_exists(element_front) && element_exists(element_behind)
      coordinate_front = get_coordinate_y(element_front)
      coordinate_behind = get_coordinate_y(element_behind)
      delta = 100

      if coordinate_front < coordinate_behind + delta
        cross = true
      else
        cross = false
      end
    end
    # puts(cross)
    return cross
  end

  # swipe down if two element cross
  def swipe_if_cross(element_front, element_behind)
    if cross_coordinate(element_front, element_behind)
      light_swipe("down")
    end
    sleep(1)
  end

  # --------------------------------------------------Localization------------------------------------------------------
  # get locale apps - Ru or Eng
  # parameter - element with text
  def get_app_location(element)
    sleep(1.5)
    if element_exists(element)
      text_element = remember(element)
      if check_cyrillic(text_element)
        locale = 'RUS'
      else
        locale = 'ENG'
      end
    else
      p "Fail localization"
    end
    p locale
    return locale
  end

  # check cyrillic symbols in string
  def check_cyrillic(str)
    regexp = /\p{Cyrillic}+.*?\.?/
    if str.match(regexp).nil?
      return false
    else
      return true
    end
  end

  # if apps support two localization, this method check exists text in different locations
  def text_with_locale(text_locale1, text_locale2)
    sleep(1)

    # $locale is global variables
    # $locale setup in first app launch
    if !$locale.nil?
      if check_cyrillic(text_locale1)
        rus_locale = "* {text CONTAINS '#{text_locale1}'}"
        eng_locale = "* {text CONTAINS '#{text_locale2}'}"
      elsif check_cyrillic(text_locale2)
        rus_locale = "* {text CONTAINS '#{text_locale2}'}"
        eng_locale = "* {text CONTAINS '#{text_locale1}'}"
      end

      if $locale == "RUS"
        return rus_locale
      elsif $locale == "ENG"
        return eng_locale
      end
    else
      # if $locale is not Rus or Eng
      # wait element on screen with text_locale1 or text_locale2
      locale_el1 = "* {text CONTAINS '#{text_locale1}'}"
      locale_el2 = "* {text CONTAINS '#{text_locale2}'}"

      if element_exists(locale_el1)
        return locale_el1
      elsif element_exists(locale_el2)
        return locale_el2
      else
        return ("No such query!")
      end
    end
  end

  # if apps support two localization, this method check exists label in different locations
  def label_with_locale(mark1, mark2)
    if element_exists("* marked:'#{mark1}'")
      return "* marked:'#{mark1}'"
    elsif element_exists("* marked:'#{mark2}'")
      return "* marked:'#{mark2}'"
    else
      return false
    end
  end

