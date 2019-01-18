require 'rspec/expectations'

module CommonMethods


  def enter_text(text)
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

  # get element coordinate
  def get_coordinate(element)
    el = query(element)
    coordinate = el[0]['rect']['center_y']
    # puts(coordinate)
    return coordinate.to_i
  end

  # if elements cross - return true, if not - false
  def cross_coordinate(element_front, element_behind)
    cross = false

    if element_exists(element_front) && element_exists(element_behind)
      coordinate_front = get_coordinate(element_front)
      coordinate_behind = get_coordinate(element_behind)
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

  # if apps support two localization, this method check exists text in different locations
  def text_with_locale(text_locale1, text_locale2)
    if element_exists("* {text BEGINSWITH '#{text_locale2}'}")
      puts (element_exists("* {text BEGINSWITH '#{text_locale2}'}"))
      return "* {text BEGINSWITH '#{text_locale2}'}"
    elsif element_exists("* {text BEGINSWITH '#{text_locale1}'}")
      puts(element_exists("* {text BEGINSWITH '#{text_locale1}'}"))
      return "* {text BEGINSWITH '#{text_locale1}'}"
    else
      return ("No such query!")
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

end
