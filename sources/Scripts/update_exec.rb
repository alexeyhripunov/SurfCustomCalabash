require 'rest-client'
require 'json'
require 'base64'


class Execution

  # path - path to dir with autotests, пример - /Users/user_name/autotests/project-test/
  def initialize(path)

    # hash with data from file scripts/data
    @all_data = get_all_data

    # login in jira
    @login = @all_data['login']

    # pass in jira
    @password = @all_data['jira_pass']

    # project key
    @key = @all_data['project_key']

    # path to dir with autotests
    @path = path

    @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@password}" ).chomp
  end

  attr_accessor :path

  # read user data from file
  def get_all_data
    Hash[*File.read("#{@path}scripts/data").split(/[, \n]+/)]
  end

  def get_test_execution(test_exec)

    key_arr = []

    for i in 1..2
      url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testexec/#{test_exec}/test?page=#{i}"

      response = RestClient.get url, {:Authorization => @auth}
      # Kernel.puts(response)
      parse_response = JSON.parse(response.body)

      # Kernel.puts(parse_response)

      parse_response.each do |keys|
        key_arr << keys['key']
      end
    end

    Kernel.puts(key_arr.sort)

    $test_keys = key_arr.sort
  end


  def delete_test_from_execution(test_exec)

    p "Start Delete"
    # begin
      url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testexec/#{test_exec}/test"
      response = RestClient.post url, {:remove => $test_keys}.to_json,
                                      {:Authorization => @auth,
                                                content_type: :json,
                                                accept: :json}
  end

  def add_test_to_execution(test_exec)

    p "Start Update"

    url = "https://jira.surfstudio.ru/rest/raven/1.0/api/testexec/#{test_exec}/test"
    response = RestClient.post url, {:add => $test_keys}.to_json,
                                    {:Authorization => @auth,
                                              content_type: :json,
                                              accept: :json}

  end

  def update_test_execution(test_exec)
    get_test_execution(test_exec)
    begin
      delete_test_from_execution(test_exec)
    rescue
      p "Timeout error"
      p "Retrying Attempt"
      delete_test_from_execution(test_exec)
    end

    add_test_to_execution(test_exec)
  end

end