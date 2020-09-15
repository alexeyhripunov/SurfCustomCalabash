require 'rest-client'
require 'base64'
require 'nokogiri'
require 'open-uri'

class GetApk

  def initialize(path)
    # хэш со всеми данными из файла scripts/data
    @all_data = get_all_data

    # название проекта в дженкинсе
    @project = @all_data['project_name_jenkins']

    # название джоба для сборки в дженкинсе
    @job_name = "#{@project}_Android_TAG"

    # адрес дженкинса
    @host = "https://jenkins.surfstudio.ru/view/Projects/view/#{@project}/job/#{@job_name}/lastSuccessfulBuild"

    # логин в дженкинсе
    @login = @all_data['login']

    # пароль дженкинса
    @password = @all_data['jenkins_pass']

    # путь до папки с автотестами
    @path = path

    # токен в дженкинсе
    @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@password}" ).chomp
  end

  # считываем данные пользователя из файла
  def get_all_data
    Hash[*File.read("#{@path}scripts/data").split(/[, \n]+/)]
  end

  def get_path_to_apk
    url = "#{@host}/api/xml?tree=artifacts%5BrelativePath%5D"

    response = RestClient.get url, {:Authorization => @auth}

    xml_parse = Nokogiri::XML(response)

    all_path = xml_parse.xpath("//relativePath")

    all_path.each do |path|
      @path_to_apk = path.content unless path.content[/qa.*\.apk$/].nil?
    end

    Kernel.puts(@path_to_apk)

    return @path_to_apk
  end

  def download_apk
    path = get_path_to_apk
    url = "#{@host}/artifact/#{path}"

    Kernel.puts('Start download')
    File.open('L.apk', "wb") do |file|
      file.write open(url, :http_basic_authentication => [@login, @password]).read
    end

    Kernel.puts('End download')
  end
end