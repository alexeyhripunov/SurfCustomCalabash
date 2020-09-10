require 'rest-client'
require 'csv'
require 'base64'
require 'benchmark'
require 'json'

$main_big_boom_address = "https://snaptest.ps.surfstudio.ru/api/"
$api_mark_as_not_finished = "mark_not_finished/"
$api_create_execution = "create_execution/"
$api_create_feature = "create_feature/"
$api_create_step = "create_step/"
$api_compare = "compare/"
$api_add_video = "add_video/"
$stack_trace_file_name = "stacktrace.log"

#запрос POST возвращающий весь response
def request_post(address, json = {})
  begin
    headers = {content_type: :json, accept: :json, Authorization: $token}
    RestClient::Request.execute(
        :url => $main_big_boom_address + address,
        :method => :post,
        :headers => headers,
        :payload => json.to_json,
        :verify_ssl => false
    )
  rescue RestClient::ExceptionWithResponse => e
    if e.http_code == 401
      fail("Указан недействительный Api-Key")
    else
      print(e.http_body)
      fail("Запрос завершился не успешно: #{e.http_code}")
    end
  end
end

# формируем json и отправляем post запрос create_execution, полученный execution_id сохраняем в глобальную переменную
def create_execution_base(execution_name, device, app_version, os_version)
  object = {
      'execution_name' => execution_name.to_s,
      'device' => device.to_s,
      'app_version' => app_version.to_s,
      'os_version' => os_version.to_s
  }
  get_execution_data = request_post($api_create_execution, object)
  execution_data = JSON.parse(get_execution_data)
  $execution_id = execution_data['execution_id']
end

# формируем json и отправляем post запрос create_feature, полученный feature_id сохраняем в глобальную переменную
def create_feature_base(execution_id, feature_name)
  object = {
      'execution_id' => execution_id,
      'feature_name' => feature_name.to_s
  }
  get_feature_data = request_post($api_create_feature, object)
  feature_data = JSON.parse(get_feature_data)
  $feature_id = feature_data['feature_id']
end

# временный запрос для фикса бд
def fix_ids
  object = {}
  get_api_key
  fix_ids = request_post($api_fix_image_paths, object)
end


# формируем json и отправляем post запрос create_step, полученный step_id сохраняем в глобальную переменную
def create_step_base(feature_id, step_name, device, resolution)
  object = {
      'feature_id' => feature_id,
      'step_name' => step_name.to_s,
      'device' => device.to_s,
      'resolution' => resolution
  }
  get_step_data = request_post($api_create_step, object)
  body_step_data = JSON.parse(get_step_data)
  $step_id = body_step_data['step_id']
end

# формируем json и отправляем post запрос mark feature as not finished
def compare_base(step_id, screenshot)
  object = {
      'step_id' => step_id,
      'photo' => screenshot.to_s,
  }
  request_post($api_compare, object)
end

# формируем json и отправляем post запрос mark feature as not finished
def video_base(feature_id, video)
  object = {
      'feature_id' => feature_id,
      'video' => video.to_s,
  }
  request_post($api_add_video, object)
end

# формируем json и отправляем post запрос помечающий фичу как not finished
def mark_feature_as_not_finished(feature_id = $feature_id)
  begin
    stack_trace = File.readlines($stack_trace_file_name).drop(1)
  rescue
    stack_trace = "file with stack trace not found"
  end
  object = {
      'feature_id' => feature_id,
      'stack_trace' => stack_trace.to_s
  }
  request_post($api_mark_as_not_finished, object)
end

# создаём прогон с передаваемым названием и сохраняем его id в глобальную переменную
def create_execution(execution_name)
  get_api_key
  $main.get_device_data
  $execution_id = create_execution_base(execution_name, $device_name, $app_version, $os_version)
end

# создаём фичу с передаваемым названием и сохраняем его id в глобальную переменную
def create_feature(execution_id = $execution_id, feature_name)
  $feature_id = create_feature_base(execution_id, feature_name)
end

# создаём шаг, делаем скриншот с устройства и запускаем процесс сравнения на сервере
def create_test_step(step_name)
  create_step(step_name)
  screenshot_path = take_screenshot(step_name)
  img_base64 = file_to_base64(screenshot_path)
  File.delete(screenshot_path)
  compare(img_base64)
end

# создаём шаг в созданном прогоне с передаваемым названием и сохраняем его id в глобальную переменную
def create_step(feature_id = $feature_id, step_name)
  $step_id = create_step_base(feature_id, step_name, $device_name, $resolution)
end

# запускаем процесс сравнения на бэке, отправляем айди шага и скриншот для сравнения
def compare(step_id = $step_id, screenshot)
  compare_base(step_id, screenshot)
end

# создаём шаг, делаем скриншот с устройства и запускаем процесс сравнения на сервере
def send_video(feature_id = $feature_id, video_path)
  sleep(2)
  video_base64 = file_to_base64(video_path)
  video_base(feature_id, video_base64)
  #File.delete(video_path)
end

# достаём из файла api key и сохраняем его в глобальную переменную
def get_api_key
  file_path = "./api_key.txt"
  if File.exist?(file_path)
    file = File.new("./api_key.txt","r:UTF-8")
    api_key = file.readlines
    $token = "Api-Key #{api_key[0]}"
    file.close
  else
    fail("Файл с Api Key не найден.")
  end
end

# сделать скриншот и записать его куда надо
def take_screenshot(name)
  path =  './reports/'
  name = "#{name}.png"
  screenshot_path = screenshot(:prefix => path, :name => name)
end

# на входе получаем фото или видео и кодируем его в base64
def file_to_base64(file_path)
  base64_file =
      File.open(file_path, "rb") do |file|
        Base64.strict_encode64(file.read)
      end
  return base64_file
end


# очищаем файл в котором находится весь вывод, если этот файл существует
def clear_file_with_stack_trace
  File.open($stack_trace_file_name, 'w'){ |file| file.truncate(0) } if File.exists?($stack_trace_file_name)
end