require 'rest-client'
require 'json'
require 'base64'

class Scenarios

  # path - path to dir with autotests, пример - /Users/user_name/autotests/project-test/
  def initialize(path)

    # hash with data from file scripts/data
    @all_data = get_all_data

    # login in jenkins
    @login = @all_data['login']

    # pass in jenkins
    @password = @all_data['jira_pass']

    # key project
    @key = @all_data['project_key']

    # path to dir with autotests
    @path = path

    # token jenkins
    @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@password}" ).chomp
  end

  attr_accessor :path

  # exec import_scenarios for import
  # this method import all scenarios in jira Xray repo
  def import_scenarios
    file_names = Dir["#{@path}features/scenarios/**/*.feature"]
    file_names.each do |file_name|
      p file_name

      response = import_feature_files(file_name)
      parse_response = JSON.parse(response.body)
      puts(parse_response)
      test_key = []
      parse_response.each{|x| test_key << x['key']}

      p test_key

      folder_name = File.basename(file_name, ".feature")

      p folder_name

      folderid = get_folderid_by_name(folder_name)

      # create folder, if dont exists
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

  # read user data from file
  def get_all_data
    Hash[*File.read("#{@path}scripts/data").split(/[, \n]+/)]
  end

  def get_id_auto_folders
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders"

    response = RestClient.get url, {:Authorization => @auth}
    # puts(response)

    parse_response = JSON.parse(response.body)
    id_auto = parse_response['folders'].select {|x| x["name"] == "Auto"}[0]['id']
    puts(id_auto)
    return id_auto
  end

  def create_folder(name, root_id)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders/#{root_id}"
    response = RestClient.post url, {:name => name}.to_json,
                                    {:Authorization => @auth,
                                             content_type: :json,
                                             accept: :json}
    # puts(response)
    return response
  end

  def get_directories_name
    dir_name = "#{@path}features/scenarios"
    all_folders = Dir.entries(dir_name).select {|entry| File.directory? File.join(dir_name, entry) and !(entry =='.' || entry == '..') }
    all_folders.sort
  end

  def get_folderid_by_name(name)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders"

    @folder_id = nil

    response = RestClient.get url, {:Authorization => @auth}
    # puts(response)
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

  def import_feature_files(file_name)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/import/feature?projectKey=#{@key}"

    RestClient.post url, { :multipart => true,
                                   :file => File.new(file_name, 'rb')},
                         { :Authorization => @auth}
  end

  def move_tests(folderid, tests)
    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testrepository/#{@key}/folders/#{folderid}/tests"
    p url
    p tests
    response = RestClient.put url, {:add => tests}.to_json,
                                   {:Authorization => @auth,
                                            content_type: :json,
                                            accept: :json}
    puts(response)
  end
end