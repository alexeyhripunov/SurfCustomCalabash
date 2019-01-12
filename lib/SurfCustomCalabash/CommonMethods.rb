require 'unicode'

module CommonMethods

  def tap_on(element)
    wait_for_elements_exist(element, :timeout=>15, :retry_frequency=>5)
    sleep(0.5)
    touch(element)
  end

  def tap_on_text(text)
    tap_on("* {text CONTAINS'#{text}'}")
  end

  # тап, если есть элемент или свайпать вниз, пока элемента нет
  def tap_or_swipe(element)
    if element_exists(element)
      sleep(1)
      touch(element)
    else
      until_element_exists(element,:action => lambda{light_swipe('down')},  :timeout => 30)
      touch(element)
    end
  end

  # делаем свайп до появления текста
  def swipe_to_text(dir, text)
    sleep(1)
    if dir == 'вверх'
      until_element_exists("* {text CONTAINS'#{text}'}", :action =>  lambda{light_swipe('up'); sleep(1)}, :timeout => 60)
    elsif dir == 'вниз'
      until_element_exists("* {text CONTAINS'#{text}'}", :action =>  lambda{light_swipe('down'); sleep(1.5)}, :timeout => 60)
    end
  end

  def enter_text(text)
    wait_for_keyboard(:timeout=>5)
    keyboard_enter_text(text)
  end

  def wait_element(element)
    wait_for_element_exists(element, :timeout=>15)
  end

  def wait_no_element(element)
    wait_for_element_does_not_exist(element, :timeout=>15)
  end

  def wait_for_screen
    wait_for_elements_exist(trait, :timeout=>25)
  end

  # свайп пока не появится нужный элемент
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

  # свайп пока элемент есть на экране
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

  # свайп элемента пока другой элемент есть на экране
  def strong_swipe_element_until_exists(dir, element, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{strong_swipe_element(element, dir)})
  end

  def light_swipe_element_until_exists(dir, element, element_destination)
    until_element_exists(element_destination,
                         :action =>  lambda{light_swipe_element(element, dir)}, :timeout=>70)
  end

  # свайп элемента пока другого элемента нет на экране
  def strong_swipe_element_until_not_exists(dir, element, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{pan(element, dir)})
  end

  def light_swipe_element_until_not_exists(dir, element, element_destination)
    until_element_does_not_exist(element_destination,
                                 :action =>  lambda{light_swipe_element(element, dir)}, :timeout=>70)
  end


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

  #### ЕЩЕ БОЛЬШЕ ПРОВЕРОК https://github.com/rspec/rspec-expectations

  # получаем рандомную строку чисел заданной длины
  def get_random_num_string(length)
    source=(0..9).to_a
    key=""
    length.times{ key += source[rand(source.size)].to_s }
    return key
  end

  # получаем рандомную текстовую строку заданной длины
  def get_random_text_string(length)
    source=("a".."z").to_a
    key=""
    length.times{ key += source[rand(source.size)].to_s }
    return key
  end

  # получаем рандомную валидную электронную почту
  def get_random_email
    return get_random_text_string(7) + "@" + get_random_text_string(2) + ".test"
  end

  # запоминаем значение поля текста у элемента
  def remember(element)
    wait_for_element_exists(element, :timeout => 5)
    sleep(1.5)
    name = query(element)
    save_name = name.first['text']
    puts(save_name)
    return save_name
  end

  def remember_last_text(element)
    wait_for_element_exists(element, :timeout => 5)
    sleep(1.5)
    name = query(element)
    save_name = name.last['text']
    puts(save_name)
    return save_name
  end

  # проверяем что указанный текст есть на экране
  def check_text(text)
    wait_for_element_exists("* {text CONTAINS'#{text}'}", :timeout => 5, :retry_frequency => 2)
  end

  # проверяем что указанного текста нет на экране
  def no_check_text(text)
    wait_for_element_does_not_exist("* {text CONTAINS'#{text}'}", :timeout => 5, :retry_frequency => 5)
  end

  # получаем координаты элемента
  def get_coordinate(element)
    el = query(element)
    coordinate = el[0]['rect']['center_y']
    # puts(coordinate)
    return coordinate.to_i
  end

  # возвращаем true если элементы накладываются друг на друга
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

  # переводим строку в строчные символы
  def down_case(text)
    Unicode::downcase text
  end

  # переводим строку в заглавные символы
  def up_case(text)
    Unicode::upcase text
  end

end
