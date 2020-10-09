require 'fileutils'
require 'diffy'

# for compare files use gem diffy https://github.com/samg/diffy

CUR_FOLDER = FileUtils.pwd

GEM_FOLDER = File.dirname(__FILE__)

# list files for update
FILES_FOR_UPDATE = File.join(GEM_FOLDER, 'files_for_update')

# path to data file
DATA_FILE = "/Scripts/data"

# read from file, files that need update
def read_file_to_arr(path_to_file)
  arr_lines = Array.new
  text = File.open(path_to_file).read
  text.each_line do |line|
    line.gsub!(/\n/, "")
    arr_lines.push(line)
  end
  return arr_lines
end

# get list files from sourcec folder in gem
def get_list_files_for_update
  list_files = read_file_to_arr(FILES_FOR_UPDATE)
  all_files = Array.new

  list_files.each do |name|
    path = File.join(GEM_FOLDER, '..', name)
    if File.file?(path)
      all_files.push(path)
    elsif File.directory?(path)
      Dir["#{path}/*"].each {|pth| all_files.push(pth)}
    end
  end

  return all_files
end

# trim folder sources from path
def get_list_for_search
  all_files = get_list_files_for_update

  all_files.each do |name|
    name.sub! /.*sources/, ''
  end

  return all_files
end

# search files, then not exist in autotest folder
def search_not_exists_files
  not_exists_files = Array.new
  get_list_for_search.each do |name|
    not_exists_files.push(name) unless File.file?(CUR_FOLDER + name)
  end

  return not_exists_files
end

# search files, then exist in autotest folder
def search_exists_files
  exists_files = Array.new
  get_list_for_search.each do |name|
    exists_files.push(name) if File.file?(CUR_FOLDER + name)
  end

  # exclude file data from list, then to don't erase user data
  exclude_str_from_arr(exists_files, DATA_FILE)
  return exists_files
end

# copy files from gem to autotest folder
def copy_files(list_for_copy)
  list_for_copy.each do |name|
    FileUtils.mkdir_p File.dirname(CUR_FOLDER + name)
    FileUtils.cp(File.join(GEM_FOLDER, '../sources', name), File.dirname(CUR_FOLDER + name))
  end
end

# add ccs style in html-report for readability
def add_css_style(file)
  file.puts("<style>")
  file.puts(Diffy::CSS)
  file.puts("</style>")
end

# compare files from gem and autotest folder
# the result would be html file with differences in compare folder
def compare_files
  need_copy = Array.new
  FileUtils.rm_rf(Dir[File.join(CUR_FOLDER, '/compare/*')])
  search_exists_files.each do |name|
    compare_result = Diffy::Diff.new(File.dirname(CUR_FOLDER + name), File.join(GEM_FOLDER, '../sources', name), :source => 'files', :format => :html)
    unless compare_result.to_s(:text).empty?
      need_copy.push(name)
      FileUtils.mkdir_p 'compare'
      File.open(File.join(CUR_FOLDER, '/compare/', "#{File.basename(name, ".*")}.html"), "w:UTF-8") do |file|
        add_css_style(file)
        file.puts(compare_result.to_s(:html))
      end
    end
  end

  return need_copy
end

# delete from array element match str_name
def exclude_str_from_arr(input_arr, str_name)
  result_arr = input_arr
  need_del = result_arr.select { |el| el.include? str_name}
  need_del.each do |value|
    result_arr.delete(value)
  end
end

# show files, then don't exixst in autotest folder
def show_files_ready_for_copy
  unless search_not_exists_files.empty?
    Kernel.puts("Файлы которых нет в текущей папке с автотестами и они будут добавлены:")
    Kernel.puts search_not_exists_files
    Kernel.puts("\n")
  end
end

# exclude files from list, then don't need update
def excludes_files_for_update(input_arr, list_files)
  all_files = list_files.split(/,\s*/)
  list_files_for_update = input_arr
  all_files.each do |name|
    exclude_str_from_arr(list_files_for_update, name)
  end

  return list_files_for_update
end

# show files, then need update and update them
def show_files_for_update
  Kernel.puts("\n")

  new_files = search_not_exists_files
  exist_files = compare_files

  if !new_files.empty? && exist_files.empty?
    show_files_ready_for_copy
    Kernel.puts("Скопировать все файлы? (y/n)")
    answer = gets

    if answer == "y\n"|| answer == "\n"
      copy_files(new_files)
      Kernel.puts("Файлы успешно добавлены!")
    end
  elsif !exist_files.empty?
    show_files_ready_for_copy
    Kernel.puts("Файлы которые уже есть в текущей папке с автотестами, но требуют обновления:")
    Kernel.puts exist_files
    Kernel.puts("\n")
    Kernel.puts("Все изменения в указанных файлах можно посмотреть в папке compare")
    Kernel.puts("Для каждого файла создан html-отчет с отображением изменений")
    Kernel.puts("\n")
    Kernel.puts("Скопировать все файлы или исключить некоторые файлы из обновления?")
    Kernel.puts("1 - Скопировать все файлы")
    Kernel.puts("2 - Исключить файлы из обновления")
    answer = gets.chomp

    if answer == "1"
      copy_files(new_files)
      copy_files(exist_files)
      Kernel.puts("Файлы успешно добавлены!")
    elsif answer == "2"
      Kernel.puts("Введите в одной строке через запятую имена файлов, которые надо исключить из обновления:")
      file_names = gets.chomp
      files_for_update = excludes_files_for_update(exist_files,file_names)

      if !files_for_update.empty? || !new_files.empty?
        Kernel.puts("Список файлов для обновления:")
        Kernel.puts files_for_update
        Kernel.puts new_files
        Kernel.puts("Скопировать все файлы? (y/n)")
        answer = gets

        if answer == "y\n"|| answer == "\n"
          copy_files(new_files)
          copy_files(files_for_update)
          Kernel.puts("Файлы успешно добавлены!")
        end
      else
        Kernel.puts("Нет файлов для обновлений!")
      end
    end
  end

  if new_files.empty? && compare_files.empty?
    Kernel.puts("В текущей папке все инфраструктурные файлы актуальны!")
  end

  Kernel.puts("\n")
end
