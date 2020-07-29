require_relative 'standard/IosCommon'
# all screens your application screens should be like this. Inheritance from IosCommon is essential!

class Test < IosCommon

  def initialize(driver)
    @driver =  driver


    ##### elements on the screen #######
    # locators and their x-platform nickname should be like that

    @trait = "SegmentedPageControllerButton"

    @auth_field = "* id:'auth_fld'"

    @main_ok_button = "* id:'bigSpaceBackground'"

    super(driver)
  end

  # all elements above should have getter for mention them from step definitions
  attr_reader *Test.new(self).instance_variables.map {|s| s[1..-1]}

  # another way to describe elements
  def tape
    "* id:'feed_rv'"
  end


  #### methods ####
  def authorize(data)
    tap_on(@auth_field)
    wait_for_keyboard
    enter_text(data)
  end
end
