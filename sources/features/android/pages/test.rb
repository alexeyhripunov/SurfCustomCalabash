require_relative 'standard/DroidCommon.rb'
# all screens your application screens should be like this. Inheritance from DroidCommon is essential!

class Test < DroidCommon
 def initialize(driver)

     @driver =  driver

     ##### elements on the screen #######

     # elements locators and their x-platform nickname should be like that

     @trait = "* id:'feed_rv'"

     @auth_field = "* id:'auth_fld'"

     @main_ok_button = "* id:'feed_vote_tutorial_go_btn'"

 end

 # all elements above should have getter for mention them from step definitions
 attr_reader *Test.new(self).instance_variables.map {|s| s[1..-1]}

    # another way to describe elements

    def tape
      "* id:'feed_rv'"
    end

    #### methods ###########

    def authorize(data)
      tap_on(@auth_field)
      wait_for_keyboard
      enter_text(data)
    end

    def test
      tap_on(@main_ok_button)
    end

end

