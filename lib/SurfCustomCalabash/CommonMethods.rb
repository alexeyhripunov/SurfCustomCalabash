require 'rspec/expectations'

# module CommonMethods


  def enter_text_from_keyboard(text)
    wait_for_keyboard(:timeout=>5)
    keyboard_enter_text(text)
  end

  # ----------------------------------------------Custom Taps-----------------------------------------------------------
  # wait element and tap
  def tap_on(element)
    wait_for_elements_exist(element, :timeout=>15, :retry_frequency=>5)
    sleep(0.5)
    touch(element)
  end

  def tap_on_text(text)
    tap_on("* {text CONTAINS'#{text}'}")
  end

  # if element exists - tap, if not - swipe until element exists and tap
  def tap_or_swipe(element)
    if element_exists(element)
      sleep(1)
      touch(element)
    else
      until_element_exists(element,:action => lambda{light_swipe('down')},  :timeout => 30)
      light_swipe('down')
      sleep(1)
      touch(element)
    end
  end

  # ----------------------------------------------------Custom Waits----------------------------------------------------
  def wait_element(element)
    wait_for_element_exists(element, :timeout=>15)
  end

  def wait_no_element(element)
    wait_for_element_does_not_exist(element, :timeout=>15)
  end

  # wait trait-element on screen
  def wait_for_screen
    wait_for_elements_exist(trait, :timeout=>25)
  end

  # ----------------------------------------------------Custom Swipe----------------------------------------------------
  def strong_swipe_until_not_exist(dir, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{strong_swipe(dir)})
  end

  def normal_swipe_until_not_exist(dir, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{normal_swipe(dir)})
  end

  def light_swipe_until_not_exist(dir, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{light_swipe( dir)})
  end

  def strong_swipe_until_exists(dir, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{strong_swipe( dir)})
  end

  def normal_swipe_until_exists(dir, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{normal_swipe( dir); sleep(2)}, :timeout=>40)
  end

  def light_swipe_until_exists(dir, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{light_swipe( dir); sleep(2)}, :timeout=>60)

  end

  def strong_swipe_element_until_exists(dir, element, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{strong_swipe_element(element, dir)})
  end

  def light_swipe_element_until_exists(dir, element, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{light_swipe_element(element, dir)}, :timeout=>70)
  end

  def strong_swipe_element_until_not_exists(dir, element, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{pan(element, dir)})
  end

  def light_swipe_element_until_not_exists(dir, element, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{light_swipe_element(element, dir)}, :timeout=>70)
  end

  def swipe_to_text(dir, text)
    sleep(1)
    if dir == 'вверх'
      until_element_exists("* {text CONTAINS'#{text}'}", :action =>  lambda{light_swipe('up'); sleep(1)}, :timeout => 60)
    elsif dir == 'вниз'
      until_element_exists("* {text CONTAINS'#{text}'}", :action =>  lambda{light_swipe('down'); sleep(1.5)}, :timeout => 60)
    end
  end

  # -------------------------------------------------Asserts------------------------------------------------------------
  def assert_eql_with_rescue(element1, element2)
    begin
      expect(element1).to eq(element2)
      true
    rescue Exception => e
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
  def remember(element)
    wait_for_element_exists(element, :timeout => 5)
    sleep(1.5)
    name = query(element)
    save_name = name.first['text']
    puts(save_name)
    return save_name
  end

  # get text from last element
  def remember_last_text(element)
    wait_for_element_exists(element, :timeout => 5)
    sleep(1.5)
    name = query(element)
    save_name = name.last['text']
    puts(save_name)
    return save_name
  end

  # wait text
  def check_text(text)
    wait_for_element_exists("* {text CONTAINS'#{text}'}", :timeout => 5, :retry_frequency => 2)
  end

  def no_check_text(text)
    wait_for_element_does_not_exist("* {text CONTAINS'#{text}'}", :timeout => 5, :retry_frequency => 5)
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

  # if apps support two localization, this method check exists text in different locations
  def text_with_locale(text_locale1, text_locale2)
    sleep(1)
    locale_el1 = "* {text CONTAINS '#{text_locale1}'}"
    locale_el2 = "* {text CONTAINS '#{text_locale2}'}"
    if element_exists(locale_el1)
      return locale_el1
    elsif element_exists(locale_el2)
      return locale_el2
    else
      fail("No such query!")
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

# end
