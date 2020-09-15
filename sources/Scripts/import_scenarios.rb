require 'rest-client'
require 'json'
require 'base64'
require_relative 'get_scenarios'

class Scenarios

  # path - путь до папки с автотестами, пример - /Users/hripunov/autotests/labirint-test/
  def initialize(path)
    # хэш со всеми данными из файла scripts/data
    @all_data = get_all_data

    # логин в джире
    @login = @all_data['login']

    # пароль в джире
    @password = @all_data['jira_pass']

    # ключ проекта в формате LABIOS
    @key = @all_data['project_key']

    # путь до папки с автотестами
    @path = path

    # токен в джире
    @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@password}" ).chomp
  end

  attr_accessor :path, :auth, :key, :login

  # для импорта необходимо запустить метод import_scenarios
  # импортирует все сценарии из проекта в репозиторий тестов, перемещая тесты в соответствующие папки
  def import_scenarios
    # через api xray больше нельзя создавать новые сценрарии, только обновлять существующие
    # поэтому сначала создаем недостающие сценарии в джира через ее api
    new_scenarios = GetScenarios.new
    if new_scenarios.get_all_scenarios_not_exists_in_jira.any?
      Kernel.puts "Будут созданы #{new_scenarios.get_all_scenarios_not_exists_in_jira.count} новых сценариев:"
      Kernel.puts new_scenarios.get_all_scenarios_not_exists_in_jira
      new_scenarios.create_all_missing_test
    end

    file_names = Dir["#{@path}features/scenarios/**/*.feature"]
    file_names.each do |file_name|
      p file_name

      response = import_feature_files(file_name)
      parse_response = JSON.parse(response.body)
      Kernel.puts(parse_response)
      test_key = []
      parse_response.each{|x| test_key << x['key']}

      p test_key

      folder_name = File.basename(file_name, ".feature")

      p folder_name

      folderid = get_folderid_by_name(folder_name)

      # если папки в репозитории нет - создаем ее
      if folderid.to_s.empty?
        cur_folder = File.basename(File.dirname(file_name))
        if cur_folder == 'scenarios'
          cur_id = get_id_auto_folders
        else
          cur_id = get_folderid_by_name(cur_folder)
          if cur_id.nil?
            create_folder(cur_folder, get_id_auto_folders)
            cur_id = get_folderid_by_name(cur_folder)
          end
        end
        p cur_folder
        create_folder(folder_name, cur_id)
      end

      folderid = get_folderid_by_name(folder_name)

      if !test_key.empty?
        move_tests(folderid, test_key)
      end
    end
  end

  # считываем данные пользователя из файла
  def get_all_data
    Hash[*File.read("#{@path}scripts/data").split(/[, \n]+/)]
  end

  # получаем id папки с авотестами в репозитории
  def get_id_auto_folders
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders"

    response = RestClient.get url, {:Authorization => @auth}
    # Kernel.puts(response)

    parse_response = JSON.parse(response.body)
    id_auto = parse_response['folders'].select {|x| x["name"] == "Auto"}[0]['id']
    Kernel.puts(id_auto)
    return id_auto
  end

  def create_folder(name, root_id)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders/#{root_id}"
    response = RestClient.post url, {:name => name}.to_json,
                               {:Authorization => @auth,
                                content_type: :json,
                                accept: :json}
    # Kernel.puts(response)
    return response
  end

  # получаем список папок с фичами
  def get_directories_name
    dir_name = "#{@path}features/scenarios"
    all_folders = Dir.entries(dir_name).select {|entry| File.directory? File.join(dir_name, entry) and !(entry =='.' || entry == '..') }
    all_folders.sort
  end

  # ищем id папки в репозитории по ее имени
  def get_folderid_by_name(name)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders"

    @folder_id = nil

    response = RestClient.get url, {:Authorization => @auth}
    # Kernel.puts(response)
    parse_response = JSON.parse(response.body)

    auto = {}
    parse_response['folders'].each{|x| x["name"] == "Auto" ? auto.update(x) : false}

    ind = auto['folders'].index{|x| x['name'] == name}

    if !ind.nil?
      @folder_id = auto['folders'][ind]['id']
    end

    if @folder_id.to_s.empty?
      auto['folders'].each_with_index do |(x, y), ind|
        x['folders'].index{|x| x["name"] == name}.nil? ? false : ind_sub = x["folders"].index{|x| x["name"] == name}
        if !ind_sub.nil?
          @folder_id = auto['folders'][ind]['folders'][ind_sub]['id']
        end
      end
    end
    p @folder_id
    return @folder_id
  end

  # имортируем фича файл
  def import_feature_files(file_name)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/import/feature?projectKey=#{@key}"

    RestClient.post url, { :multipart => true,
                           :file => File.new(file_name, 'rb')},
                    { :Authorization => @auth}
  end

  # перемещаем выгруженные сценарии в нужную папку
  def move_tests(folderid, tests)
    # https://jira.surfstudio.ru/rest/raven/1.0/folderStructure/moveTests?destinationId=1757
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders/#{folderid}/tests"
    p url
    p tests
    response = RestClient.put url, {:add => tests}.to_json,
                              {:Authorization => @auth,
                               content_type: :json,
                               accept: :json}
    Kernel.puts(response)
  end
end
