#On the start execution we should create all Page objects.

if ENV['PLATFORM'] == 'ios'

  Before do |scenario|
    init_ios
  end

elsif ENV['PLATFORM'] == 'android'

  Before do |scenario|
    init_android
  end

else puts('Error in hooks.rb file!')

end




