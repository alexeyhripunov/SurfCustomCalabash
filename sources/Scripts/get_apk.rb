require 'rest-client'
require 'base64'
require 'nokogiri'
require 'open-uri'

class GetApk

  def initialize(path)
    # hash with data from file - scripts/data
    @all_data = get_all_data

    # project name in jenkins
    @project = @all_data['project_name_jenkins']

    # job name build app in jenkins
    @job_name = "#{@project}_Android_TAG"

    # jenkins link
    @host = "https://jenkins.surfstudio.ru/view/Projects/view/#{@project}/job/#{@job_name}/lastSuccessfulBuild"

    # login in jenkins
    @login = @all_data['login']

    # pass in jenkins
    @password = @all_data['jenkins_pass']

    # path to dir with autotests
    @path = path

    # token jenkins
    @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@password}" ).chomp
  end

  # read user data from file
  def get_all_data
    Hash[*File.read("#{@path}scripts/data").split(/[, \n]+/)]
  end

  def get_path_to_apk
    url = "#{@host}/api/xml?tree=artifacts%5BrelativePath%5D"

    response = RestClient.get url, {:Authorization => @auth}

    xml_parse = Nokogiri::XML(response)

    path_to_apk = xml_parse.xpath("//relativePath").first.content

    puts(path_to_apk)

    return path_to_apk
  end

  def download_apk
    path = get_path_to_apk
    url = "#{@host}/artifact/#{path}"

    puts('Start download')
    File.open('L.apk', "wb") do |file|
      file.write open(url, :http_basic_authentication => [@login, @password]).read
    end

    puts('End download')
  end
end