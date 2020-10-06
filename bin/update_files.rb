require 'fileutils'
require 'diffy'

# папка из которой происходит запуск гема
CUR_FOLDER = FileUtils.pwd

# папка в которой расположены исходные файлы гема
GEM_FOLDER = File.dirname(__FILE__)

# файл со списком файлов для обновления
FILES_FOR_UPDATE = File.join(GEM_FOLDER, 'files_for_update')


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

# получаем список файлов для обновления из папки sources в геме
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
  # puts all_files
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

# ищем файлы из списка для обновления которых нет в папке с автотестами
def search_not_exists_files
  not_exists_files = Array.new
  get_list_for_search.each do |name|
    not_exists_files.push(name) unless File.file?(CUR_FOLDER + name)
  end
  # puts not_exists_files
  return not_exists_files
end

# ищем файлы из списка для обновления которые есть в папке с автотестами
def search_exists_files
  exists_files = Array.new
  get_list_for_search.each do |name|
    exists_files.push(name) if File.file?(CUR_FOLDER + name)
  end

  # puts exists_files
  return exists_files
end

# копируем файлы
def copy_files
  search_not_exists_files.each do |name|
    FileUtils.cp(File.join(GEM_FOLDER, '../sources', name), File.dirname(CUR_FOLDER + name))
  end
end

# добавляем css в выходной файл сравнения файлов для читабельности
def add_css_style(file)
  file.puts("<style>")
  file.puts(Diffy::CSS)
  file.puts("</style>")
end

# сравниваем файлы которые есть в папке автотестах и геме
# результатом сравнения будут файлы html в папке compare
def compare_files
  FileUtils.mkdir_p 'compare'
  search_exists_files.each do |name|
    compare_result = Diffy::Diff.new(File.dirname(CUR_FOLDER + name), File.join(GEM_FOLDER, '../sources', name), :source => 'files', :format => :html)
    unless compare_result.to_s(:text).empty?
      puts("Файл #{name} не пуст")
      File.open(File.join(CUR_FOLDER, '/compare/', "#{File.basename(name, ".*")}.html"), "w:UTF-8") do |file|
        add_css_style(file)
        file.puts(compare_result.to_s(:html))
      end
    end
  end
end
