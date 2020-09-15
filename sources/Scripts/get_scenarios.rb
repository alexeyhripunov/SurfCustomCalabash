require_relative 'import_scenarios'

class GetScenarios

  def initialize
    @user_data = Scenarios.new("..")
  end

  # получить название всех сценариев из папки scenarios
  def get_all_scenarios_name
    @lines = Array.new
    all_scenarios = Array.new

    # путь до папки с фича файлами
    file_names = Dir["./**/*.feature"]

    # проходимся по всем файлам
    file_names.each do |name|

      # записываем все строки файла в массив
      text=File.open(name).read
      text.gsub!(/\r\n?/, "\n")
      text.each_line do |line|
        @lines.push(line)
      end
    end

    # получаем все названия сценариев
    @lines.each do |x|
      if x.match(/Сценарий:/)
        x.sub!(/Сценарий:/,'')
        all_scenarios.push(x.strip)
      elsif x.match(/Структура сценария:/)
        x.sub!(/Структура сценария:/,'')
        all_scenarios.push(x.strip)
      end
    end
    # Kernel.puts all_scenarios.count
    return all_scenarios
  end

  # получить все не закомментрованные сценарии
  def get_all_work_scenarios
    all_work_scenarios = Array.new
    get_all_scenarios_name.each do |x|
      all_work_scenarios.push(x) unless x.match(/#/)
    end
    # Kernel.puts all_work_scenarios
    # p all_work_scenarios.count
    return all_work_scenarios
  end

  # получить все закомментированные сценарии
  def get_all_comment_scenarios
    all_comment_scenarios = Array.new
    scenarios_name = Array.new
    get_all_scenarios_name.each do |x|
      all_comment_scenarios.push(x) if x.match(/#/)
    end

    all_comment_scenarios.each do |x|
      x.sub!(/#/,'')
      scenarios_name.push(x.strip)
    end

    Kernel.puts scenarios_name
    p scenarios_name.count
    return scenarios_name
  end

  # получить все сценарии с одинаковым именем
  def show_all_duplicate_scenarios
    if get_all_scenarios_name.duplicate.reject { |c| c.empty? }.any?
      Kernel.puts "В репозитории найдены сценарии с одинаковыми названиями:"
      Kernel.puts get_all_scenarios_name.duplicate
    else
      Kernel.puts "В репозитории нет сценариев с одинаковыми названиями"
    end
  end

  # получаем все названия и ключи сценариев автотестов из джиры
  def get_scenarios_name_from_jira
    # @user_data = Scenarios.new("..")
    jql = "project%20=%20#{@user_data.key}%20AND%20issuetype%20=%20Test%20AND%20\"Test%20Type\"%20=%20Cucumber"
    fields = "summary"
    max_results = "500"
    url = "https://jira.surfstudio.ru/rest/api/2/search?jql=#{jql}&fields=#{fields}&maxResults=#{max_results}"

    response = RestClient.get url, {:Authorization => @user_data.auth}

    parse_response = JSON.parse(response.body)

    summary = {}

    parse_response['issues'].each {|x| summary[x['key']] = x['fields'].values[0]}
    # Kernel.puts summary
    # Kernel.puts summary.count
    return summary
  end

  # получаем все сценарии которых нет в джире
  def get_all_scenarios_not_exists_in_jira
    get_all_work_scenarios.sort - get_scenarios_name_from_jira.values.sort
  end

  # получаем все названия сценариев и их ключи которые есть в джире, но нет в репозитории
  def get_all_scenarios_not_exists_in_repo
    Hash[get_scenarios_name_from_jira.to_a - get_scenarios_name_from_jira.extract_subhash(get_all_work_scenarios).to_a]
  end

  def show_all_scenarios_not_exists_in_repo
    Kernel.puts get_all_scenarios_not_exists_in_repo.values
  end

  # выводит в консоль информацию о недостающих или лишних тестах в джире
  def show_difference_tests
    if get_all_scenarios_not_exists_in_jira.any?
      Kernel.puts "В jira не хватает #{get_all_scenarios_not_exists_in_jira.count} сценариев, которые есть в репозитории:"
      Kernel.puts get_all_scenarios_not_exists_in_jira
      Kernel.puts "\n"
    end
    if get_all_scenarios_not_exists_in_repo.any?
      Kernel.puts "В jira найдены #{get_all_scenarios_not_exists_in_repo.count} сценариев, которых нет в репозитории:"
      Kernel.puts get_all_scenarios_not_exists_in_repo.values
      Kernel.puts "\n"
    end
    unless get_all_scenarios_not_exists_in_repo.any? || get_all_scenarios_not_exists_in_jira.any?
      Kernel.puts "В jira есть все сценарии из репозитория и нет лишних"
    end
  end

  # создаем тест в репозитории в джире
  def create_cucumber_test(test_name)
    # user_data = Scenarios.new("..")
    url = "https://jira.surfstudio.ru/rest/api/2/issue/"
    body = {"fields"=>{"project"=>{"key"=>@user_data.key},
                       "summary"=>test_name,
                       "issuetype"=>{"name"=>"Test"},
                       "assignee"=>{"name"=>@user_data.login},
                       "customfield_10200"=>{"value"=>"Cucumber"}}}

    response = RestClient.post url, body.to_json,
                               {:Authorization => @user_data.auth,
                                content_type: :json,
                                accept: :json}
    return JSON.parse(response.body)['key']
  end

  # создаем все недостающие тесты в джире
  def create_all_missing_test
    Kernel.puts "Созданы сценарии:" if get_all_scenarios_not_exists_in_jira.any?
    get_all_scenarios_not_exists_in_jira.each do |name|
      Kernel.puts "#{create_cucumber_test(name)} #{name}"
    end
  end

  # удаляем тест из jira
  def delete_issues_by_key(key)
    # user_data = Scenarios.new("..")
    url = "https://jira.surfstudio.ru/rest/api/2/issue/#{key}"
    response = RestClient.delete url,{:Authorization => @user_data.auth}
    response.code
  end

  # удаляем тесты, которые есть в джира, но нет в репо
  def delete_all_waste_tests
    get_all_scenarios_not_exists_in_repo.each do |k, v|
      Kernel.puts "Сценарий: #{v} успешно удален" if delete_issues_by_key(k) == 204
    end
  end
end

# find duplicate in array
class Array
  def duplicate
    duplicate = Array.new
    duplicate.push(self.uniq.
        map { | e | [self.count(e), e] }.
        select { | c, _ | c > 1 }.
        sort.reverse.
        map { | _, e | "#{e}" })

    return duplicate
  end
end

# extract subhash from hash
class Hash
  def extract_subhash(extract)
    self.select{|k, v| extract.include?(v)}
  end
end

