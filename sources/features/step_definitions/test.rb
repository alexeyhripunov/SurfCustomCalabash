#language: ru
# Definitions or Ruby for all steps in Gherkin

И (/^Я запускаю приложение$/) do
  wait_for do
    !query('*').empty?
  end
end


And (/^I start the application$/) do
  wait_for do
    !query('*').empty?
  end

end

Тогда(/^Я использую Gmail для авторизации$/) do
  $user = CREDENTIALS[:twitter]
  $test.wait_element($test.auth_field)
end


Тогда(/^Я использую Gmail для авторизации$/) do
  $user = CREDENTIALS[:twitter]
  $test.wait_element($test.auth_field)
  $test.authorize("#{$user[:token].to_s}%#{$user[:number].to_s}")
end


And(/^I use gmail for authorization$/) do
  $user = CREDENTIALS[:twitter]
  $test.wait_element($test.auth_field)
  $test.authorize("#{$user[:token].to_s}%#{$user[:number].to_s}")
end

И(/^Я авторизуюсь от разных пользователей$/) do
  if ENV['PLATFORM'] == 'ios'
    steps %Q{И Я авторизуюсь под пользователем для ios}
  elsif ENV['PLATFORM'] == 'android'
    steps %Q{И Я авторизуюсь под пользователем для android}
  end
end
