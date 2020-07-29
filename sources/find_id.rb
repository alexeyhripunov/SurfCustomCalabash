class Find

  def find_id_dev(path)

    sub_lines = Array.new

    # path to dir with r-files
    file_names = Dir["#{path}/**/R.java"]

    file_names.each do |name|
      puts(name)

      lines = Array.new
      text=File.open(name).read
      text.gsub!(/\r\n?/, "\n")
      text.each_line do |line|
        lines.push(line)
      end

      if !lines.index{|x| x.match(/public static final class id {/)}.nil?

        start_push = false
        lines.each do |x|
          if !x.match(/public static final class id {/).nil?
            start_push = true
          elsif !x.match(/\s}/).nil?
            start_push = false
          end
          if start_push and x.match(/public static final class id {/).nil? and x.match(/}/).nil?
            x.sub! /.*int/, ''
            x.sub! /\=.*/, ''
            sub_lines.push(x.strip)
          end
        end
            sub_lines.uniq!
      end
    end

    p sub_lines.length
    return sub_lines
  end

  def find_id_test(path)
    sub_lines = Array.new

    file_names = Dir["#{path}/**/*.rb"]
    file_names.each do |name|

      puts(name)

      lines = Array.new
      text=File.open(name).read
      text.gsub!(/\r\n?/, "\n")
      text.each_line do |line|
        lines.push(line)
      end

      if !lines.index{|x| x.match(/def initialize/)}.nil?

        start_push = false
        lines.each do |x|
          if !x.match(/\@/).nil?
            start_push = true
          elsif !x.match(/end}/).nil?
            start_push = false
          end
          if start_push and !x.match(/@/).nil? and
                            !x.match(/\* id/).nil? and
                            x.match(/CONTAINS/).nil? and
                            x.match(/\.widget/).nil? and
                            x.match(/\.BEGINSWITH/).nil? and
                            x.match(/text:/).nil? and
            x.sub! /.*\* id:'/, ''
            x.sub! /'".*/, ''
            x.sub! /' index:.*/, ''
            sub_lines.push(x.strip)
          end
        end

        sub_lines.uniq!
      end
    end

    p sub_lines.length
    return sub_lines
  end

  def get_miss_id(dev_path, test_path)
    miss_id = find_id_test(test_path) - find_id_dev(dev_path)

    File.open("miss_id.txt", "w+") do |f|
      miss_id.each{|x| f.puts(x)}
    end
  end
end